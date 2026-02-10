from django.urls import path
from .views import StudentListView, CreateStudentView, UpdateStudentView

urlpatterns = [
    path('list/', StudentListView.as_view(), name='student_list'),
    path('create/', CreateStudentView.as_view(), name='create_student'),
    path('update/', UpdateStudentView.as_view(), name='update_student'),
]