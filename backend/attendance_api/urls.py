from django.urls import path
from .views import (
    StudentListView, CreateStudentView, UpdateStudentView,
    TeacherListView, CreateTeacherView, UpdateTeacherView
)

urlpatterns = [
    # STUDENTS
    path('students/list/', StudentListView.as_view(), name='student_list'),
    path('students/create/', CreateStudentView.as_view(), name='create_student'),
    path('students/update/', UpdateStudentView.as_view(), name='update_student'),

    # TEACHERS
    path('teachers/list/', TeacherListView.as_view(), name='teacher_list'),
    path('teachers/create/', CreateTeacherView.as_view(), name='create_teacher'),
    path('teachers/update/', UpdateTeacherView.as_view(), name='update_teacher'),
]
