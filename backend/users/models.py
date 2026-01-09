from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """
    Custom User model with role-based access and timezone support
    """
    ROLE_CHOICES = [
        ('user', 'User'),
        ('admin', 'Admin'),
        ('superadmin', 'Super Admin'),
    ]
    
    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default='user',
        help_text='User role for access control'
    )
    timezone = models.CharField(
        max_length=50,
        default='UTC',
        help_text='User timezone for time conversions'
    )
    google_calendar_token = models.JSONField(
        null=True,
        blank=True,
        help_text='Stored OAuth tokens for Google Calendar (Admin only)'
    )
    phone_number = models.CharField(
        max_length=20,
        blank=True,
        null=True,
        help_text='Phone number for WhatsApp notifications'
    )
    
    class Meta:
        db_table = 'users'
        ordering = ['-date_joined']
    
    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"
    
    def is_admin_role(self):
        """Check if user has admin or superadmin role"""
        return self.role in ['admin', 'superadmin']
    
    def is_super_admin(self):
        """Check if user is super admin"""
        return self.role == 'superadmin'
