from django.urls import path
from .views import StudentListView, CreateStudentView, UpdateStudentView, TeacherListView, CreateTeacherView, UpdateTeacherView

urlpatterns = [
    path('list/', StudentListView.as_view(), name='student_list'),
    path('create/', CreateStudentView.as_view(), name='create_student'),
    path('update/', UpdateStudentView.as_view(), name='update_student'),
    path('list/', TeacherListView.as_view(), name='teacher_list'),
    path('create/', CreateTeacherView.as_view(), name='create_teacher'),
    path('update/', UpdateTeacherView.as_view(), name='update_teacher'),
]