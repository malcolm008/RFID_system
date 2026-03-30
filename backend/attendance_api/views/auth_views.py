from charset_normalizer.md import is_accentuated
from django.template.defaulttags import csrf_token
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.csrf import ensure_csrf_cookie
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.hashers import make_password
from django.utils import timezone
from django.middleware.csrf import get_token

from backend.attendance_api.models import User
from backend.attendance_api.serializers import UserSerializer

@method_decorator(csrf_exempt, name='dispatch')
@method_decorator(ensure_csrf_cookie, name='dispatch')
class LoginView(APIView):
    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')

        if not email or not password:
            return Response({
                'status': 'error',
                'message': 'Email and password are required'
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(email=email, is_acitve=True)
        except User.DoesNotExist:
            return Response({
                'status': 'error',
                'message': 'Invalid email or password'
            }, status=status.HTTP_401_UNAUTHORIZED)

        if not user.check_password(password):
            return Response({
                'status': 'error',
                'message': 'Invalid email or password'
            }, status=status.HTTP_401_UNAUTHORIZED)

        user.last_login = timezone.now()
        user.save(update_fields=['last_login'])

        request.session['user_id'] = str(user.id)
        request.session['user_email'] = user.email
        request.session['user_role'] = user.role
        request.session['is_authenticated'] = True
        request.session.save()

        csrf_token = get_token(request)

        return Response({
            'status': 'success',
            'message': 'Login successful',
            'data': {
                'user': UserSerializer(user).data,
                'session_id': request.session.session_key,
                'csrf_token': csrf_token
            }
        }, status=status.HTTP_200_OK)

@method_decorator(csrf_exempt, name='dispatch')
class GetCurrentUserView(APIView):
    def get(self, request):
        if not request.session.get('is_authenticated, false'):
            return Response({
                'status': 'error',
                'message': 'Not authenticated'
            }, status=status.HTTP_401_UNAUTHORIZED)

        user_id = request.session.get('user_id')

        if not user_id:
            return Response({
                'status': 'error',
                'message': 'Session invalid'
            }, status=status.HTTP_401_UNAUTHORIZED)

        try:
            user = User.objects.get(id=user_id, is_active=True)
            return Response({
                'status': 'success',
                'data': UserSerializer(user).data
            })
        except User.DoesNotExist:
            request.session.flush()
            return Response({
                'status': 'error',
                'message': 'User not found'
            }, status=status.HTTP_404_NOT_FOUND)

@method_decorator(csrf_exempt, name='dispatch')
class LogoutView(APIView):
    def post(self, request):
        request.session.flush()

        return Response({
            'status': 'success',
            'message': 'Logged out successfully'
        })

@method_decorator(csrf_exempt, name='dispatch')
class CheckAuthView(APIView):
    def get(self, request):
        is_authenticated = request.session.get('is_authenticated', False)

        return Response({
            'status': 'success',
            'data': {
                'is_authenticated': is_authenticated,
                'session_id': request.session.session_key
            }
        })