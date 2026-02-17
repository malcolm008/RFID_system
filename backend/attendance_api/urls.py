from django.urls import path
from .views import (
    StudentListView, CreateStudentView, UpdateStudentView, DeleteStudentView, BulkDeleteStudentView,
    TeacherListView, CreateTeacherView, UpdateTeacherView, DeleteTeacherView, BulkDeleteTeacherView,
    DeviceListView, CreateDeviceView, UpdateDeviceView, DeleteDeviceView, BulkDeleteDeviceView,
    CreateProgramView, UpdateProgramView, ProgramListView, DeleteProgramView, BulkDeleteProgramView,
    CourseListView, CreateCourseView, UpdateCourseView, DeleteCourseView, BulkDeleteCourseView
)

urlpatterns = [
    # STUDENTS
    path('students/list/', StudentListView.as_view(), name='student_list'),
    path('students/create/', CreateStudentView.as_view(), name='create_student'),
    path('students/update/', UpdateStudentView.as_view(), name='update_student'),
    path('students/delete/', DeleteStudentView.as_view(), name='delete_student'),
    path('students/bulk-delete/', BulkDeleteStudentView.as_view(), name='bulk-delete_student'),

    # TEACHERS
    path('teachers/list/', TeacherListView.as_view(), name='teacher_list'),
    path('teachers/create/', CreateTeacherView.as_view(), name='create_teacher'),
    path('teachers/update/', UpdateTeacherView.as_view(), name='update_teacher'),
    path('teachers/delete/', DeleteTeacherView.as_view(), name='delete_teacher'),
    path('teachers/bulk-delete/', BulkDeleteTeacherView.as_view(), name='bulk_delete_teacher'),


    #DEVICE
    path('devices/list/', DeviceListView.as_view()),
    path('devices/create', CreateDeviceView.as_view()),
    path('devices/update', UpdateDeviceView.as_view()),
    path('devices/delete/', DeleteDeviceView.as_view()),
    path('devices/bulk-delete/', BulkDeleteDeviceView.as_view()),


    #PROGRAM
    path('programs/list/', ProgramListView.as_view()),
    path('programs/create/', CreateProgramView.as_view()),
    path('programs/update/', UpdateProgramView.as_view()),
    path('programs/delete/', DeleteProgramView.as_view()),
    path('programs/bulk-delete/', BulkDeleteProgramView.as_view()),


    #COURSE
    path('courses/list/', CourseListView.as_view(), name='course_list'),
    path('courses/create/', CreateCourseView.as_view(), name='create_course'),
    path('courses/update/', UpdateCourseView.as_view(), name='update_course'),
    path('courses/delete/', DeleteCourseView.as_view(), name='delete_course'),
    path('courses/bulk-delete/', BulkDeleteCourseView.as_view(), name='bulk_delete_course'),

]
