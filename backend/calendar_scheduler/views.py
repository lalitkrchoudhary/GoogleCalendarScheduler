from django.http import JsonResponse
from django.views.decorators.http import require_http_methods


@require_http_methods(["GET"])
def api_status(request):
    """API status check endpoint"""
    return JsonResponse({
        'status': 'ok',
        'message': 'Calendar Scheduler API is running!',
        'version': '1.0.0',
        'endpoints': {
            'auth': '/api/auth/',
            'availability': '/api/availability/',
            'bookings': '/api/bookings/',
            'admin': '/admin/',
        }
    })
