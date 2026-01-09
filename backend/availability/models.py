from django.db import models
from django.core.exceptions import ValidationError
from users.models import User


class Availability(models.Model):
    """
    Admin availability slots
    """
    admin = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='availabilities',
        limit_choices_to={'role__in': ['admin', 'superadmin']}
    )
    date = models.DateField(help_text='Available date')
    start_time = models.TimeField(help_text='Start time for availability')
    end_time = models.TimeField(help_text='End time for availability')
    slot_duration = models.IntegerField(
        default=30,
        help_text='Duration of each slot in minutes (15, 30, or 60)'
    )
    is_active = models.BooleanField(
        default=True,
        help_text='Whether this availability is active'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'availability'
        ordering = ['-date', 'start_time']
        verbose_name_plural = 'Availabilities'
        unique_together = ['admin', 'date', 'start_time']
    
    def __str__(self):
        return f"{self.admin.username} - {self.date} ({self.start_time}-{self.end_time})"
    
    def clean(self):
        """Validate that end_time is after start_time"""
        if self.start_time >= self.end_time:
            raise ValidationError('End time must be after start time')
        
        if self.slot_duration not in [15, 30, 60]:
            raise ValidationError('Slot duration must be 15, 30, or 60 minutes')
    
    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)
    
    def get_time_slots(self):
        """
        Generate time slots based on start_time, end_time, and slot_duration
        Returns list of (start_time, end_time) tuples
        """
        from datetime import datetime, timedelta
        
        slots = []
        current_time = datetime.combine(self.date, self.start_time)
        end_datetime = datetime.combine(self.date, self.end_time)
        delta = timedelta(minutes=self.slot_duration)
        
        while current_time + delta <= end_datetime:
            slot_start = current_time.time()
            slot_end = (current_time + delta).time()
            slots.append((slot_start, slot_end))
            current_time += delta
        
        return slots
