from rest_framework.views import APIView
from rest_framework.response import Response
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator

class CsrfExemptAPIView(APIView):
    @method_decorator(csrf_exempt)
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)

class DeleteBaseView(CsrfExemptAPIView):
    model = None
    model_name= "Item"

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
                'message': f'{self.model_name} delted successfully'
            })
        except self.model.DoesNotExist:
            return Response({
                'status': 'error',
                'message': f'{self.model_name} not found'
            }, status=404)

class BulkDeleteBaseView(CsrfExemptAPIView):
    model = None
    model_name = "Item"

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