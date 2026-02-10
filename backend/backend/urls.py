from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('attendance_api/students/', include('attendance_api.urls')),
    path('attendance_api/teachers/', include('attendance_api.urls')),
]