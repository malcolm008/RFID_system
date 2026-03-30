# attendance_api/views/__init__.py

from .base_views import CsrfExemptAPIView, DeleteBaseView, BulkDeleteBaseView
from .auth_views import LoginView, GetCurrentUserView, LogoutView

# You'll need to create similar files for Teacher, Device, Program, Course, Timetable views
# For now, let's export what we have

__all__ = [
    'CsrfExemptAPIView',
    'DeleteBaseView',
    'BulkDeleteBaseView',
    'LoginView',
    'GetCurrentUserView',
    'LogoutView',
]