from rest_framework import serializers
from .models import Booking
from users.serializers import UserSerializer
from datetime import datetime


class BookingSerializer(serializers.ModelSerializer):
    """Serializer for Booking model"""
    user_details = UserSerializer(source='user', read_only=True)
    admin_details = UserSerializer(source='admin', read_only=True)
    
    class Meta:
        model = Booking
        fields = [
            'id', 'user', 'user_details', 'admin', 'admin_details',
            'date', 'start_time', 'end_time', 'timezone', 'meeting_purpose',
            'meeting_link', 'calendar_event_id', 'status', 'notes',
            'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'meeting_link', 'calendar_event_id',
            'created_at', 'updated_at'
        ]
    
    def validate(self, attrs):
        """Validate booking data"""
        date = attrs.get('date')
        start_time = attrs.get('start_time')
        end_time = attrs.get('end_time')
        admin = attrs.get('admin')
        
        # Check if booking is in the past
        booking_datetime = datetime.combine(date, start_time)
        if booking_datetime < datetime.now():
            raise serializers.ValidationError({
                'date': 'Cannot book meetings in the past'
            })
        
        # Check if start_time is before end_time
        if start_time >= end_time:
            raise serializers.ValidationError({
                'end_time': 'End time must be after start time'
            })
        
        # Check if admin has role permissions
        if admin and not admin.is_admin_role():
            raise serializers.ValidationError({
                'admin': 'Selected user is not an admin'
            })
        
        return attrs


class BookingCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating bookings"""
    
    class Meta:
        model = Booking
        fields = [
            'admin', 'date', 'start_time', 'end_time',
            'timezone', 'meeting_purpose', 'notes'
        ]


class BookingUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating bookings (reschedule)"""
    
    class Meta:
        model = Booking
        fields = ['date', 'start_time', 'end_time', 'meeting_purpose', 'notes']


class CancelBookingSerializer(serializers.Serializer):
    """Serializer for cancelling bookings"""
    reason = serializers.CharField(required=False, allow_blank=True)
