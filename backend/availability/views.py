from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Q
from datetime import datetime
from .models import Availability
from .serializers import AvailabilitySerializer, TimeSlotSerializer
from bookings.models import Booking


class AvailabilityListCreateView(generics.ListCreateAPIView):
    """List and create availability"""
    serializer_class = AvailabilitySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        queryset = Availability.objects.all()
        
        # Filter by admin if provided
        admin_id = self.request.query_params.get('admin')
        if admin_id:
            queryset = queryset.filter(admin_id=admin_id)
        
        # Filter by date range
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')
        if start_date:
            queryset = queryset.filter(date__gte=start_date)
        if end_date:
            queryset = queryset.filter(date__lte=end_date)
        
        # Role-based filtering
        if user.is_super_admin():
            return queryset
        elif user.is_admin_role():
            return queryset.filter(admin=user)
        else:
            # Regular users can see all active availabilities
            return queryset.filter(is_active=True)
        
        return queryset
    
    def perform_create(self, serializer):
        # Automatically set admin to current user if they are admin
        user = self.request.user
        if user.is_admin_role():
            serializer.save(admin=user)
        else:
            # Non-admins cannot create availability
            raise permissions.PermissionDenied("Only admins can create availability")


class AvailabilityDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Retrieve, update, or delete availability"""
    queryset = Availability.objects.all()
    serializer_class = AvailabilitySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.is_super_admin():
            return Availability.objects.all()
        elif user.is_admin_role():
            return Availability.objects.filter(admin=user)
        return Availability.objects.filter(is_active=True)


class AvailableTimeSlotsView(APIView):
    """Get available time slots for a specific date and admin"""
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        admin_id = request.query_params.get('admin')
        date_str = request.query_params.get('date')
        
        if not admin_id or not date_str:
            return Response({
                'error': 'Both admin and date parameters are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            date = datetime.strptime(date_str, '%Y-%m-%d').date()
        except ValueError:
            return Response({
                'error': 'Invalid date format. Use YYYY-MM-DD'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Get availability for the date
        availabilities = Availability.objects.filter(
            admin_id=admin_id,
            date=date,
            is_active=True
        )
        
        if not availabilities.exists():
            return Response({
                'date': date_str,
                'admin': admin_id,
                'slots': []
            })
        
        # Get existing bookings for this admin on this date
        bookings = Booking.objects.filter(
            admin_id=admin_id,
            date=date,
            status__in=['confirmed', 'pending']
        )
        
        # Create a dict of booked slots
        booked_slots = {}
        for booking in bookings:
            key = (booking.start_time, booking.end_time)
            booked_slots[key] = booking.id
        
        # Generate all time slots
        all_slots = []
        for availability in availabilities:
            slots = availability.get_time_slots()
            for start_time, end_time in slots:
                slot_key = (start_time, end_time)
                is_available = slot_key not in booked_slots
                
                all_slots.append({
                    'start_time': start_time,
                    'end_time': end_time,
                    'is_available': is_available,
                    'booking_id': booked_slots.get(slot_key)
                })
        
        # Sort by start_time
        all_slots.sort(key=lambda x: x['start_time'])
        
        serializer = TimeSlotSerializer(all_slots, many=True)
        
        return Response({
            'date': date_str,
            'admin': admin_id,
            'slots': serializer.data
        })
