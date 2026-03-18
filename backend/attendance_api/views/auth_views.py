from django.core.serializers import serialize
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from django.utils import timezone
import jwt
import datetime
from django.conf import settings

from ..models import User
from ..serializers import UserSerializer, LoginSerializer, RegisterSerializer

SECRET_KEY = 'your-secret-key-here-change-in-production'

@method_decorator(csrf_exempt, name='dispatch')
class LoginView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)

        if not serializer.is_valid():
            return Response({
                'status': 'error',
                'message': serializer.errors
            }, status= status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        password = serializer.validated_data['password']

        try:
            user = User.objects.get(email=email, is_active=True)
        except User.DoesNotExist:
            return Response({
                'status': 'error',
                'message': 'Invalid email or Password'
            }, status=status.HTTP_401_UNAUTHORIZED)

        if not user.check_password(password):
            return Response({
                'status': 'error',
                'message': 'Invalid email or password'
            }, status=status.HTTP_401_UNAUTHORIZED)

        user.last_login = timezone.now()
        user.save(update_fields=['last_login'])

        token = jwt.encode({
            'user_id': str(user.id),
            'email': user.email,
            'role': user.role,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=1)
        }, SECRET_KEY, algorithm='HS256')

        return Response({
            'status': 'success',
            'message': 'Login successful',
            'data': {
                'user': UserSerializer(user).data,
                'token': token
            }
        }, status=status.HTTP_200_OK)

@method_decorator(csrf_exempt, name='dispatch')
class RegisterView(APIView):
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)

        if serializer.is_valid():
            user = serializer.save()
            return Response({
                'status': 'success',
                'message': 'User registered successfully',
                'data': UserSerializer(user).data
            }, status=status.HTTP_201_CREATED)

        return Response({
            'status': 'error',
            'message': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

@method_decorator(csrf_exempt, name='dispatch')
class GetCurrentUserView(APIView):
    def get(self, request):
        auth_header = request.headers.get('Authorization', '')

        if not auth_header.startswith('Bearer '):
            return Response({
                'status': 'error',
                'message': 'Invalid authorization header'
            }, status=status.HTTP_401_UNAUTHORIZED)

        token = auth_header.replace('Bearer ', '')
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
            user_id = payload.get('user_id')

            user = User.objects.get(id=user_id, is_active=True)

            return Response({
                'status': 'success',
                'data': UserSerializer(user).data
            })
        except jwt.ExpiredSignatureError:
            return Response({
                'status': 'error',
                'message': 'Token has expired'
            }, status=status.HTTP_401_UNAUTHORIZED)
        except jwt.InvalidTokenError:
            return Response({
                'status': 'error',
                'message': 'Invalid token'
            }, status=status.HTTP_401_UNAUTHORIZED)
        except User.DoesNotExist:
            return Response({
                'status': 'error',
                'message': 'User not found'
            }, status=status.HTTP_404_NOT_FOUND)

@method_decorator(csrf_exempt, name='dispatch')
class LogoutView(APIView):
    def post(self, request):
        # With JWT, logout is handled client-side
        # You can implement token blacklist here if needed
        return Response({
            'status': 'success',
            'message': 'Logged out successfully'
        })