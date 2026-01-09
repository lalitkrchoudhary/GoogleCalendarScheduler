from django.db import models
from django.core.exceptions import ValidationError
from users.models import User


class Booking(models.Model):
    """
    Meeting booking model
    """
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('cancelled', 'Cancelled'),
    ]
    
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='bookings',
        help_text='User who booked the meeting'
    )
    admin = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='admin_bookings',
        limit_choices_to={'role__in': ['admin', 'superadmin']},
        help_text='Admin with whom the meeting is booked'
    )
    date = models.DateField(help_text='Meeting date')
    start_time = models.TimeField(help_text='Meeting start time')
    end_time = models.TimeField(help_text='Meeting end time')
    timezone = models.CharField(
        max_length=50,
        default='UTC',
        help_text='Timezone of the booking'
    )
    meeting_purpose = models.TextField(
        help_text='Purpose or agenda of the meeting'
    )
    meeting_link = models.URLField(
        blank=True,
        help_text='Video meeting link (Google Meet, Zoom, etc.)'
    )
    calendar_event_id = models.CharField(
        max_length=255,
        blank=True,
        help_text='Google Calendar event ID'
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='confirmed'
    )
    notes = models.TextField(
        blank=True,
        help_text='Additional notes'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'bookings'
        ordering = ['-date', '-start_time']
        constraints = [
            models.UniqueConstraint(
                fields=['admin', 'date', 'start_time'],
                condition=~models.Q(status='cancelled'),
                name='unique_active_booking'
            )
        ]
    
    def __str__(self):
        return f"{self.user.username} meeting with {self.admin.username} on {self.date} at {self.start_time}"
    
    def clean(self):
        """Validate booking"""
        if self.start_time >= self.end_time:
            raise ValidationError('End time must be after start time')
        
        # Prevent users from booking with themselves
        if self.user_id == self.admin_id:
            raise ValidationError('Cannot book a meeting with yourself')
        
        # Check for overlapping bookings (excluding current instance and cancelled)
        from django.db.models import Q
        overlapping = Booking.objects.filter(
            admin=self.admin,
            date=self.date,
            status__in=['confirmed', 'pending']
        ).exclude(pk=self.pk)
        
        for booking in overlapping:
            if (self.start_time < booking.end_time and 
                self.end_time > booking.start_time):
                raise ValidationError(
                    f'This slot overlaps with an existing booking from '
                    f'{booking.start_time} to {booking.end_time}'
                )
    
    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)
