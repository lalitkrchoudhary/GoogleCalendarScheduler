from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes
from django.db.models import Q
from datetime import datetime, timedelta
from .models import Booking
from .serializers import (
    BookingSerializer, BookingCreateSerializer,
    BookingUpdateSerializer, CancelBookingSerializer
)
from calendar_scheduler.integrations.email_service import EmailService


class BookingListCreateView(generics.ListCreateAPIView):
    """List and create bookings"""
    permission_classes = [permissions.IsAuthenticated]
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return BookingCreateSerializer
        return BookingSerializer
    
    def get_queryset(self):
        user = self.request.user
        queryset = Booking.objects.all()
        
        # Filter by status
        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
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
            # Admins see their own bookings
            return queryset.filter(admin=user)
        else:
            # Regular users see only their bookings
            return queryset.filter(user=user)
        
        return queryset
    
    def create(self, request, *args, **kwargs):
        """Override create to return full booking data"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        booking = serializer.save(user=request.user)
        
        # Create Google Calendar event if admin has connected calendar
        try:
            from calendar_scheduler.integrations.google_calendar import GoogleCalendarService
            
            if booking.admin.google_calendar_token:
                print(f"Creating Google Calendar event for booking {booking.id}")
                event_data = GoogleCalendarService.create_event(booking.admin, booking)
                
                if event_data:
                    booking.meeting_link = event_data.get('meet_link', '') or event_data.get('html_link', '')
                    booking.calendar_event_id = event_data.get('event_id', '')
                    booking.save()
                    print(f"Event created: {booking.meeting_link}")
                else:
                    print("Failed to create event (service returned None)")
        except Exception as e:
            print(f"Error in calendar integration: {str(e)}")
            # Don't fail the booking if calendar fails
        
        # Send confirmation emails
        try:
            EmailService.send_booking_confirmation_email(booking)
        except Exception as e:
            print(f"Error sending confirmation email: {str(e)}")
            # Don't fail the booking if email fails
        
        # Return full booking data using BookingSerializer
        response_serializer = BookingSerializer(booking)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)


class BookingDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Retrieve, update, or delete booking"""
    permission_classes = [permissions.IsAuthenticated]
    
    def get_serializer_class(self):
        if self.request.method in ['PUT', 'PATCH']:
            return BookingUpdateSerializer
        return BookingSerializer
    
    def get_queryset(self):
        user = self.request.user
        if user.is_super_admin():
            return Booking.objects.all()
        elif user.is_admin_role():
            return Booking.objects.filter(Q(admin=user) | Q(user=user))
        else:
            return Booking.objects.filter(user=user)


class CancelBookingView(APIView):
    """Cancel a booking"""
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request, pk):
        try:
            booking = Booking.objects.get(pk=pk)
        except Booking.DoesNotExist:
            return Response({
                'error': 'Booking not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Check permissions
        user = request.user
        if not (user.id == booking.user_id or 
                user.id == booking.admin_id or 
                user.is_super_admin()):
            return Response({
                'error': 'Permission denied'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Check if already cancelled
        if booking.status == 'cancelled':
            return Response({
                'error': 'Booking is already cancelled'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Cancel the booking
        booking.status = 'cancelled'
        booking.save()
        
        # TODO: Delete Google Calendar event
        
        # Send cancellation emails
        try:
            EmailService.send_booking_cancellation_email(booking)
        except Exception as e:
            print(f"Error sending cancellation email: {str(e)}")
            # Don't fail the cancellation if email fails
        
        return Response({
            'message': 'Booking cancelled successfully',
            'booking': BookingSerializer(booking).data
        })


class RescheduleBookingView(APIView):
    """Reschedule a booking"""
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request, pk):
        try:
            booking = Booking.objects.get(pk=pk)
        except Booking.DoesNotExist:
            return Response({
                'error': 'Booking not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Check permissions
        user = request.user
        if user.id != booking.user_id and not user.is_super_admin():
            return Response({
                'error': 'Only the booking owner can reschedule'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Store old values for email notification
        old_date = booking.date
        old_start_time = booking.start_time
        old_end_time = booking.end_time
        
        # Update booking
        serializer = BookingUpdateSerializer(booking, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        updated_booking = serializer.save()
        
        # TODO: Update Google Calendar event
        
        # Send reschedule notification emails
        try:
            EmailService.send_booking_reschedule_email(
                updated_booking, 
                old_date, 
                old_start_time, 
                old_end_time
            )
        except Exception as e:
            print(f"Error sending reschedule email: {str(e)}")
            # Don't fail the reschedule if email fails
        
        return Response({
            'message': 'Booking rescheduled successfully',
            'booking': BookingSerializer(updated_booking).data
        })


class UserDashboardView(APIView):
    """Get user dashboard data"""
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        user = request.user
        today = datetime.now().date()
        
        # Upcoming bookings
        upcoming_bookings = Booking.objects.filter(
            user=user,
            date__gte=today,
            status__in=['confirmed', 'pending']
        ).order_by('date', 'start_time')[:10]
        
        # Past bookings
        past_bookings = Booking.objects.filter(
            user=user,
            date__lt=today
        ).order_by('-date', '-start_time')[:5]
        
        # Statistics
        total_bookings = Booking.objects.filter(user=user).count()
        cancelled_bookings = Booking.objects.filter(user=user, status='cancelled').count()
        
        return Response({
            'upcoming_bookings': BookingSerializer(upcoming_bookings, many=True).data,
            'past_bookings': BookingSerializer(past_bookings, many=True).data,
            'statistics': {
                'total': total_bookings,
                'cancelled': cancelled_bookings,
                'completed': past_bookings.count()
            }
        })


class AdminDashboardView(APIView):
    """Get admin dashboard data"""
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        user = request.user
        
        if not user.is_admin_role():
            return Response({
                'error': 'Admin access required'
            }, status=status.HTTP_403_FORBIDDEN)
        
        today = datetime.now().date()
        
        # Today's bookings
        today_bookings = Booking.objects.filter(
            admin=user,
            date=today,
            status__in=['confirmed', 'pending']
        ).order_by('start_time')
        
        # Upcoming bookings (next 7 days)
        week_later = today + timedelta(days=7)
        upcoming_bookings = Booking.objects.filter(
            admin=user,
            date__range=[today, week_later],
            status__in=['confirmed', 'pending']
        ).order_by('date', 'start_time')
        
        # Statistics
        total_bookings = Booking.objects.filter(admin=user).count()
        pending_bookings = Booking.objects.filter(admin=user, status='pending').count()
        
        return Response({
            'today_bookings': BookingSerializer(today_bookings, many=True).data,
            'upcoming_bookings': BookingSerializer(upcoming_bookings, many=True).data,
            'statistics': {
                'total': total_bookings,
                'pending': pending_bookings,
                'today': today_bookings.count()
            }
        })
