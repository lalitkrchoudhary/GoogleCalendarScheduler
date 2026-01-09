from django.core.mail import send_mail
from django.conf import settings
from datetime import datetime
import logging

logger = logging.getLogger(__name__)


class EmailService:
    """
    Service for sending email notifications for bookings
    """
    
    @staticmethod
    def send_booking_confirmation_email(booking):
        """
        Send confirmation email when a booking is created
        
        Args:
            booking: Booking instance
        """
        try:
            # Format date and time
            booking_date = booking.date.strftime('%A, %B %d, %Y')
            start_time = booking.start_time.strftime('%I:%M %p')
            end_time = booking.end_time.strftime('%I:%M %p')
            
            # Email to user
            user_subject = f'Booking Confirmed: Meeting with {booking.admin.get_full_name() or booking.admin.username}'
            user_message = f"""
Hello {booking.user.get_full_name() or booking.user.username},

Your meeting has been confirmed!

Meeting Details:
----------------
Date: {booking_date}
Time: {start_time} - {end_time} ({booking.timezone})
With: {booking.admin.get_full_name() or booking.admin.username}
Purpose: {booking.meeting_purpose}

{f'Meeting Link: {booking.meeting_link}' if booking.meeting_link else 'Meeting link will be provided soon.'}

{f'Notes: {booking.notes}' if booking.notes else ''}

If you need to cancel or reschedule, please contact us.

Best regards,
Calendar Scheduler Team
            """
            
            send_mail(
                subject=user_subject,
                message=user_message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[booking.user.email],
                fail_silently=True,
            )
            
            # Email to admin
            admin_subject = f'New Booking: Meeting with {booking.user.get_full_name() or booking.user.username}'
            admin_message = f"""
Hello {booking.admin.get_full_name() or booking.admin.username},

You have a new booking!

Meeting Details:
----------------
Date: {booking_date}
Time: {start_time} - {end_time} ({booking.timezone})
With: {booking.user.get_full_name() or booking.user.username} ({booking.user.email})
Purpose: {booking.meeting_purpose}

{f'Meeting Link: {booking.meeting_link}' if booking.meeting_link else 'Meeting link will be provided soon.'}

{f'Notes: {booking.notes}' if booking.notes else ''}

Best regards,
Calendar Scheduler Team
            """
            
            send_mail(
                subject=admin_subject,
                message=admin_message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[booking.admin.email],
                fail_silently=True,
            )
            
            logger.info(f"Booking confirmation emails sent for booking {booking.id}")
            
        except Exception as e:
            logger.error(f"Failed to send booking confirmation email: {str(e)}")
    
    @staticmethod
    def send_booking_cancellation_email(booking):
        """
        Send notification email when a booking is cancelled
        
        Args:
            booking: Booking instance
        """
        try:
            # Format date and time
            booking_date = booking.date.strftime('%A, %B %d, %Y')
            start_time = booking.start_time.strftime('%I:%M %p')
            end_time = booking.end_time.strftime('%I:%M %p')
            
            # Email to user
            user_subject = f'Booking Cancelled: Meeting with {booking.admin.get_full_name() or booking.admin.username}'
            user_message = f"""
Hello {booking.user.get_full_name() or booking.user.username},

Your meeting has been cancelled.

Cancelled Meeting Details:
--------------------------
Date: {booking_date}
Time: {start_time} - {end_time} ({booking.timezone})
With: {booking.admin.get_full_name() or booking.admin.username}
Purpose: {booking.meeting_purpose}

If you would like to reschedule, please book a new appointment.

Best regards,
Calendar Scheduler Team
            """
            
            send_mail(
                subject=user_subject,
                message=user_message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[booking.user.email],
                fail_silently=True,
            )
            
            # Email to admin
            admin_subject = f'Booking Cancelled: Meeting with {booking.user.get_full_name() or booking.user.username}'
            admin_message = f"""
Hello {booking.admin.get_full_name() or booking.admin.username},

A booking has been cancelled.

Cancelled Meeting Details:
--------------------------
Date: {booking_date}
Time: {start_time} - {end_time} ({booking.timezone})
With: {booking.user.get_full_name() or booking.user.username} ({booking.user.email})
Purpose: {booking.meeting_purpose}

Best regards,
Calendar Scheduler Team
            """
            
            send_mail(
                subject=admin_subject,
                message=admin_message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[booking.admin.email],
                fail_silently=True,
            )
            
            logger.info(f"Booking cancellation emails sent for booking {booking.id}")
            
        except Exception as e:
            logger.error(f"Failed to send booking cancellation email: {str(e)}")
    
    @staticmethod
    def send_booking_reschedule_email(booking, old_date, old_start_time, old_end_time):
        """
        Send notification email when a booking is rescheduled
        
        Args:
            booking: Updated Booking instance
            old_date: Previous date
            old_start_time: Previous start time
            old_end_time: Previous end time
        """
        try:
            # Format old date and time
            old_booking_date = old_date.strftime('%A, %B %d, %Y')
            old_start = old_start_time.strftime('%I:%M %p')
            old_end = old_end_time.strftime('%I:%M %p')
            
            # Format new date and time
            new_booking_date = booking.date.strftime('%A, %B %d, %Y')
            new_start = booking.start_time.strftime('%I:%M %p')
            new_end = booking.end_time.strftime('%I:%M %p')
            
            # Email to user
            user_subject = f'Booking Rescheduled: Meeting with {booking.admin.get_full_name() or booking.admin.username}'
            user_message = f"""
Hello {booking.user.get_full_name() or booking.user.username},

Your meeting has been rescheduled.

Previous Meeting:
-----------------
Date: {old_booking_date}
Time: {old_start} - {old_end}

New Meeting Details:
--------------------
Date: {new_booking_date}
Time: {new_start} - {new_end} ({booking.timezone})
With: {booking.admin.get_full_name() or booking.admin.username}
Purpose: {booking.meeting_purpose}

{f'Meeting Link: {booking.meeting_link}' if booking.meeting_link else 'Meeting link will be provided soon.'}

{f'Notes: {booking.notes}' if booking.notes else ''}

Best regards,
Calendar Scheduler Team
            """
            
            send_mail(
                subject=user_subject,
                message=user_message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[booking.user.email],
                fail_silently=True,
            )
            
            # Email to admin
            admin_subject = f'Booking Rescheduled: Meeting with {booking.user.get_full_name() or booking.user.username}'
            admin_message = f"""
Hello {booking.admin.get_full_name() or booking.admin.username},

A booking has been rescheduled.

Previous Meeting:
-----------------
Date: {old_booking_date}
Time: {old_start} - {old_end}

New Meeting Details:
--------------------
Date: {new_booking_date}
Time: {new_start} - {new_end} ({booking.timezone})
With: {booking.user.get_full_name() or booking.user.username} ({booking.user.email})
Purpose: {booking.meeting_purpose}

{f'Meeting Link: {booking.meeting_link}' if booking.meeting_link else 'Meeting link will be provided soon.'}

{f'Notes: {booking.notes}' if booking.notes else ''}

Best regards,
Calendar Scheduler Team
            """
            
            send_mail(
                subject=admin_subject,
                message=admin_message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[booking.admin.email],
                fail_silently=True,
            )
            
            logger.info(f"Booking reschedule emails sent for booking {booking.id}")
            
        except Exception as e:
            logger.error(f"Failed to send booking reschedule email: {str(e)}")
