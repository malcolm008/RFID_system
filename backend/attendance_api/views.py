from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from .models import Student, Teacher
from .serializers import StudentSerializer, TeacherSerializer


# Create a base class that explicitly disables CSRF
class CsrfExemptAPIView(APIView):
    @method_decorator(csrf_exempt)
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)

# Now all views inherit from CsrfExemptAPIView
class StudentListView(CsrfExemptAPIView):
    def get(self, request):
        try:
            students = Student.objects.all()
            serializer = StudentSerializer(students, many=True)
            return Response({
                'status': 'success',
                'data': serializer.data
            })
        except Exception as e:
            return Response({
                'status': 'error',
                'message': str(e)
            }, status=500)

class CreateStudentView(CsrfExemptAPIView):
    def post(self, request):
        print("=== CREATE STUDENT REQUEST ===")
        print(f"Headers: {dict(request.headers)}")
        print(f"Data: {request.data}")
        print(f"Method: {request.method}")
        print("==============================")

        # Handle raw JSON data if it comes as string
        if isinstance(request.data, str):
            import json
            try:
                data = json.loads(request.data)
            except json.JSONDecodeError:
                return Response({
                    'status': 'error',
                    'message': 'Invalid JSON format'
                }, status=400)
        else:
            data = request.data

        serializer = StudentSerializer(data=data)

        if serializer.is_valid():
            try:
                student = serializer.save()
                print(f"Student saved: ID={student.id}")
                return Response({
                    'status': 'success',
                    'data': StudentSerializer(student).data
                }, status=201)
            except Exception as e:
                print(f"Database error: {e}")
                return Response({
                    'status': 'error',
                    'message': f'Database error: {str(e)}'
                }, status=500)

        print(f"Validation errors: {serializer.errors}")
        return Response({
            'status': 'error',
            'message': serializer.errors
        }, status=400)

class UpdateStudentView(CsrfExemptAPIView):
    def post(self, request):
        if 'id' not in request.data:
            return Response({
                'status': 'error',
                'message': 'Missing student ID'
            }, status=400)

        try:
            student = Student.objects.get(id=request.data['id'])
            serializer = StudentSerializer(student, data=request.data, partial=True)

            if serializer.is_valid():
                serializer.save()
                return Response({
                    'status': 'success',
                    'data': serializer.data
                })

            return Response({
                'status': 'error',
                'message': serializer.errors
            }, status=400)

        except Student.DoesNotExist:
            return Response({
                'status': 'error',
                'message': f'Student not found'
            }, status=404)

class TeacherListView(CsrfExemptAPIView):
    def get(self, request):
        try:
            teachers = Teacher.objects.all()
            serializer = TeacherSerializer(teachers, many=True)
            return Response({
                'status': 'success',
                'data': serializer.data
            })
        except Exception as e:
            return Response({
                'status': 'error',
                'message': str(e)
            }, status=500)

class CreateTeacherView(CsrfExemptAPIView):
    def post(self, request):
        print("=== CREATE TEACHER REQUEST ===")
        print(f"Headers: {dict(request.headers)}")
        print(f"Data: {request.data}")
        print(f"Method: {request.method}")
        print("===============================")

        if isinstance(request.data, str):
            import json
            try:
                data = json.loads(request.data)
            except json.JSONDecodeError:
                return Response({
                    'status': 'error',
                    'message': 'Invalid JSON format'
                }, status=400)
        else:
            data = request.data

        serializer = TeacherSerializer(data=data)

        if serializer.is_valid():
            try:
                teacher = serializer.save()
                print(f"Teacher saved: ID={teacher.id}")
                return Response({
                    'status': 'success',
                    'data': TeacherSerializer(teacher).data
                }, status=201)
            except Exception as e:
                print(f"Database error: {e}")
                return Response({
                    'status': 'error',
                    'message': f'Database error: {str(e)}'
                }, status=500)

        print(f"Validation errors: {serializer.errors}")
        return Response({
            'status': 'error',
            'message': serializer.errors
        }, status=400)

class UpdateTeacherView(CsrfExemptAPIView):
    def post(self, request):
        if 'id' not in request.data:
            return Response({
                'status': 'error',
                'message': 'Missing teacher ID'
            }, status=400)

        try:
            teacher = Teacher.objects.get(id=request.data['id'])
            serializer = TeacherSerializer(teacher, data=request.data, partial=True)

            if serializer.is_valid():
                serializer.save()
                return Response({
                    'status': 'success',
                    'data': serializer.data
                })

            return Response({
                'status': 'error',
                'message': serializer.errors
            }, status=400)

        except Teacher.DoesNotExist:
            return Response({
                'status': 'error',
                'message': f'Student not found'
            }, status=400)
