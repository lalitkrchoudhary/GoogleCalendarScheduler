
import os
import google_auth_oauthlib.flow
import googleapiclient.discovery
from google.oauth2.credentials import Credentials
from django.conf import settings
from rest_framework.exceptions import ValidationError

class GoogleCalendarService:
    """
    Service to handle Google Calendar interactions
    """
    SCOPES = [
        'https://www.googleapis.com/auth/calendar',
        'https://www.googleapis.com/auth/calendar.events',
        'https://www.googleapis.com/auth/userinfo.email',
        'openid'
    ]
    
    @staticmethod
    def get_flow():
        """Get OAuth flow object"""
        client_config = {
            "web": {
                "client_id": settings.GOOGLE_CLIENT_ID,
                "project_id": os.environ.get('GOOGLE_PROJECT_ID', 'calendar-scheduler'),
                "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                "token_uri": "https://oauth2.googleapis.com/token",
                "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
                "client_secret": settings.GOOGLE_CLIENT_SECRET,
                "redirect_uris": [settings.GOOGLE_REDIRECT_URI]
            }
        }
        
        return google_auth_oauthlib.flow.Flow.from_client_config(
            client_config=client_config,
            scopes=GoogleCalendarService.SCOPES
        )

    @staticmethod
    def get_auth_url(user_id=None):
        """Generate the authorization URL"""
        flow = GoogleCalendarService.get_flow()
        flow.redirect_uri = settings.GOOGLE_REDIRECT_URI
        
        state = str(user_id) if user_id else None
        
        authorization_url, state = flow.authorization_url(
            access_type='offline',
            include_granted_scopes='true',
            prompt='consent',
            state=state
        )
        return authorization_url, state

    @staticmethod
    def exchange_code(code):
        """Exchange authorization code for credentials"""
        flow = GoogleCalendarService.get_flow()
        flow.redirect_uri = settings.GOOGLE_REDIRECT_URI
        
        try:
            flow.fetch_token(code=code)
            credentials = flow.credentials
            
            return {
                'token': credentials.token,
                'refresh_token': credentials.refresh_token,
                'token_uri': credentials.token_uri,
                'client_id': credentials.client_id,
                'client_secret': credentials.client_secret,
                'scopes': credentials.scopes
            }
        except Exception as e:
            raise ValidationError(f"Failed to exchange code: {str(e)}")

    @staticmethod
    def get_credentials(user):
        """Reconstruct credentials from stored user tokens"""
        if not user.google_calendar_token:
            return None
            
        token_data = user.google_calendar_token
        
        return Credentials(
            token=token_data['token'],
            refresh_token=token_data.get('refresh_token'),
            token_uri=token_data.get('token_uri', "https://oauth2.googleapis.com/token"),
            client_id=token_data.get('client_id', os.environ.get('GOOGLE_CLIENT_ID')),
            client_secret=token_data.get('client_secret', os.environ.get('GOOGLE_CLIENT_SECRET')),
            scopes=token_data.get('scopes')
        )

    @staticmethod
    def create_event(user, booking):
        """Create a Google Calendar event for the booking"""
        creds = GoogleCalendarService.get_credentials(user)
        if not creds:
            return None
            
        try:
            service = googleapiclient.discovery.build('calendar', 'v3', credentials=creds)
            
            # Convert booking time to RFC3339 format
            start_datetime = f"{booking.date}T{booking.start_time}"
            end_datetime = f"{booking.date}T{booking.end_time}"
            
            event = {
                'summary': f"{booking.meeting_purpose} - {booking.user.username}",
                'description': f"Meeting with {booking.user.first_name} {booking.user.last_name}\n\nPurpose: {booking.meeting_purpose}\nNotes: {booking.notes or 'None'}",
                'start': {
                    'dateTime': start_datetime,
                    'timeZone': booking.timezone,
                },
                'end': {
                    'dateTime': end_datetime,
                    'timeZone': booking.timezone,
                },
                'attendees': [
                    {'email': booking.user.email},
                    {'email': booking.admin.email},
                ],
                'conferenceData': {
                    'createRequest': {
                        'requestId': f"booking-{booking.id}",
                        'conferenceSolutionKey': {'type': 'hangoutsMeet'}
                    }
                },
            }
            
            # Create event with conference data (Google Meet link)
            event = service.events().insert(
                calendarId='primary',
                body=event,
                conferenceDataVersion=1
            ).execute()
            
            return {
                'event_id': event.get('id'),
                'meet_link': event.get('hangoutLink'),
                'html_link': event.get('htmlLink')
            }
            
        except Exception as e:
            print(f"Error creating calendar event: {str(e)}")
            return None  # Fail silently for now, don't block booking
