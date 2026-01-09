from rest_framework import serializers
from .models import Availability
from users.serializers import UserSerializer
from datetime import datetime, timedelta


class AvailabilitySerializer(serializers.ModelSerializer):
    """Serializer for Availability model"""
    admin_details = UserSerializer(source='admin', read_only=True)
    total_slots = serializers.SerializerMethodField()
    
    class Meta:
        model = Availability
        fields = [
            'id', 'admin', 'admin_details', 'date', 'start_time',
            'end_time', 'slot_duration', 'is_active', 'total_slots',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'admin', 'created_at', 'updated_at']
    
    def get_total_slots(self, obj):
        """Calculate total number of slots"""
        return len(obj.get_time_slots())
    
    def validate(self, attrs):
        """Validate availability data"""
        date = attrs.get('date')
        start_time = attrs.get('start_time')
        end_time = attrs.get('end_time')
        
        # Check if date is in the past
        if date < datetime.now().date():
            raise serializers.ValidationError({
                'date': 'Cannot create availability for past dates'
            })
        
        # Check if start_time is before end_time
        if start_time >= end_time:
            raise serializers.ValidationError({
                'end_time': 'End time must be after start time'
            })
        
        return attrs


class TimeSlotSerializer(serializers.Serializer):
    """Serializer for individual time slots"""
    start_time = serializers.TimeField()
    end_time = serializers.TimeField()
    is_available = serializers.BooleanField()
    booking_id = serializers.IntegerField(allow_null=True, required=False)
