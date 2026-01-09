from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    RegisterView, LoginView, CurrentUserView,
    ChangePasswordView, UserListView, ListAdminsView
)

from .views_oauth import GoogleAuthURLView, GoogleAuthCallbackView

app_name = 'users'

urlpatterns = [
    # Authentication
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # Google OAuth
    path('google/url/', GoogleAuthURLView.as_view(), name='google-auth-url'),
    path('google/callback/', GoogleAuthCallbackView.as_view(), name='google-auth-callback'),
    
    # User profile
    path('me/', CurrentUserView.as_view(), name='current-user'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
    
    # User management
    path('', UserListView.as_view(), name='user-list'),
    path('admins/', ListAdminsView.as_view(), name='admin-list'),
]
