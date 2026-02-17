from django.core.serializers import serialize
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from .models import Student, Teacher, Device, Program, Course
from .serializers import StudentSerializer, TeacherSerializer, DeviceSerializer, ProgramSerializer, \
    CourseSerializer


# Create a base class that explicitly disables CSRF
class CsrfExemptAPIView(APIView):
    @method_decorator(csrf_exempt)
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)


class DeleteBaseView(CsrfExemptAPIView):
    model = None
    model_name = "Item"

    def post(self, request):
        item_id = request.data.get('id')

        if not item_id:
            return Response({
                'status': 'error',
                'message': f'{self.model_name} ID is required'
            }, status=400)

        try:
            item = self.model.objects.get(id=item_id)
            item.delete()
            return Response({
                'status': 'success',
                'message': f'{self.model_name} deleted successfully'
            })
        except self.model.DoesNotExist:
            return Response({
                'status': 'error',
                'message': f'{self.model_name} not found'
            }, status=404)

class BulkDeleteBaseView(CsrfExemptAPIView):
    model = None
    model_name = "Items"

    def post(self, request):
        if not self.model:
            return Response({
                'status': 'error',
                'message': 'Model not configured'
            }, status=500)

        ids = request.data.get('ids')

        if not ids or not isinstance(ids, list):
            return Response({
                'status': 'error',
                'message': f'A list of {self.model_name} IDs is required'
            }, status=400)

        deleted_count, _ = self.model.objects.filter(id__in=ids).delete()

        return Response({
            'status': 'success',
            'message': f'{deleted_count} {self.model_name}(s) deleted successfully'
        })

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


class BulkDeleteStudentView(BulkDeleteBaseView):
    model = Student
    model_name = "Student"


class DeleteStudentView(DeleteBaseView):
    model = Student
    model_name = "Student"

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

class BulkDeleteTeacherView(BulkDeleteBaseView):
    model = Teacher
    model_name = "Teacher"

class DeleteTeacherView(DeleteBaseView):
    model = Teacher
    model_name = "Teacher"

class DeviceListView(CsrfExemptAPIView):
    def get(self, request):
        devices = Device.objects.all().order_by('-lastSeen')
        serializer = DeviceSerializer(devices, many=True)
        return Response({
            'status': 'success',
            'data': serializer.data
        })

class CreateDeviceView(CsrfExemptAPIView):
    def post(self, request):
        serializer = DeviceSerializer(data=request.data)

        if serializer.is_valid():
            device = serializer.save()
            return Response({
                'status': 'success',
                'data': DeviceSerializer(device).data
            }, status=201)

        return Response({
            'status': 'error',
            'message': serializer.errors
        }, status=400)

class UpdateDeviceView(CsrfExemptAPIView):
    def post(self, request):
        device_id = request.data.get('id')

        if not device_id:
            return Response({
                'status': 'error',
                'message': 'Device ID is required'
            }, status=400)

        try:
            device = Device.objects.get(id=device_id)
        except Device.DoesNotExist:
            return Response({
                'status': 'error',
                'message': 'Device not found'
            }, status=404)

        serializer = DeviceSerializer(device, data=request.data, partial=True)

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


class BulkDeleteDeviceView(BulkDeleteBaseView):
    model = Device
    model_name = "Device"

class DeleteDeviceView(DeleteBaseView):
    model = Device
    model_name = "Device"

class CreateProgramView(CsrfExemptAPIView):
    def post(self, request):
        print("🔵 Received POST data:", request.data)  # log incoming data
        serializer = ProgramSerializer(data=request.data)
        if serializer.is_valid():
            program = serializer.save()
            print("🟢 Program saved with ID:", program.id)
            return Response({
                'status': 'success',
                'data': serializer.data
            }, status=201)
        else:
            print("🔴 Validation errors:", serializer.errors)  # <-- this is crucial
            return Response({
                'status': 'error',
                'message': serializer.errors
            }, status=400)

class ProgramListView(CsrfExemptAPIView):
    def get(self, request):
        programs = Program.objects.all()
        serializer = ProgramSerializer(programs, many=True)

        return Response({
            'status': 'success',
            'data': serializer.data
        })

class UpdateProgramView(CsrfExemptAPIView):
    def post(self, request):
        program_id = request.data.get('id')

        if not program_id:
            return Response({
                'status': 'error',
                'message': 'Class ID is required'
            }, status=400)

        try:
            program = Program.objects.get(id=program_id)
        except Program.DoesNotExist:
            return Response({
                'status': 'error',
                'message': 'Class not found'
            }, status=400)

        serializer = ProgramSerializer(
            program,
            data=request.data,
            partial=True
        )

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


class BulkDeleteProgramView(BulkDeleteBaseView):
    model = Program
    model_name = "Program"

class DeleteProgramView(DeleteBaseView):
    model = Program
    model_name = "Program"

class CourseListView(CsrfExemptAPIView):
    def get(self, request):
        courses = Course.objects.select_related('Program').all()
        serializer = CourseSerializer(courses, many=True)

        return Response({
            'status': 'success',
            'data': serializer.data
        })

class CreateCourseView(CsrfExemptAPIView):
    def post(self, request):
        serializer = CourseSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response({
                'status': 'success',
                'data': serializer.data
            }, status=status.HTTP_201_CREATED)

        return Response({
            'status': 'error',
            'message': serializer.errors
        }, status=400)

class UpdateCourseView(CsrfExemptAPIView):
    def post(self, request):
        course_id = request.data.get('id')

        if not course_id:
            return Response({
                'status': 'error',
                'message': 'Course ID is required'
            }, status=400)

        try:
            course = Course.objects.get(id=course_id)
        except Course.DoesNotExist:
            return Response({
                'status': 'error',
                'message': 'Course not found'
            }, status=400)

        serializer = CourseSerializer(
            course,
            data=request.data,
            partial=True
        )

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


class BulkDeleteCourseView(BulkDeleteBaseView):
    model = Course
    model_name = "Course"

class DeleteCourseView(DeleteBaseView):
    model = Course
    model_name = "Course"