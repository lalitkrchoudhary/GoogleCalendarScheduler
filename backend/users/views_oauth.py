
from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from calendar_scheduler.integrations.google_calendar import GoogleCalendarService

from django.shortcuts import redirect
from django.http import HttpResponse

class GoogleAuthURLView(APIView):
    """
    Get the Google OAuth authorization URL
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        if not request.user.is_admin_role():
            return Response(
                {'error': 'Only admins can connect Google Calendar'}, 
                status=status.HTTP_403_FORBIDDEN
            )
            
        auth_url, state = GoogleCalendarService.get_auth_url(user_id=request.user.id)
        return Response({'auth_url': auth_url})


class GoogleAuthCallbackView(APIView):
    """
    Handle the Google OAuth callback
    """
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        code = request.query_params.get('code')
        state = request.query_params.get('state')  # This is the user_id
        error = request.query_params.get('error')
        
        if error:
            return HttpResponse(f"Error from Google: {error}", status=400)
            
        if not code:
            return HttpResponse("No code provided", status=400)
            
        try:
            # Exchange code for tokens
            tokens = GoogleCalendarService.exchange_code(code)
            
            # Find user by ID (state)
            from users.models import User
            if state:
                try:
                    user = User.objects.get(id=int(state))
                    user.google_calendar_token = tokens
                    user.save()
                    return HttpResponse(
                        "<h1>Success!</h1><p>Google Calendar connected successfully. You can close this window and return to the app.</p>"
                    )
                except User.DoesNotExist:
                    return HttpResponse("Invalid state: User not found", status=400)
            else:
                 return HttpResponse("No state provided to identify user", status=400)

        except Exception as e:
             return HttpResponse(f"Error connecting calendar: {str(e)}", status=400)
