from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from .models import Service
from cabins.models import Cabin, AreaCode, PostCode


class ServiceTests(APITestCase):
    """Test the Service model"""
    def setUp(self):
        self.url=reverse('create_service')
        self.area=AreaCode.objects.create(area="Helsinki", post_code = "00770")
        #self.post=PostCode.objects.create(p_code=self.area, postal_district="Helsinki")
        Service.objects.create(area=self.area,
                                name="Sauna 66",
                                description="Sauna 66 description",
                                service_price=25,
                                vat_price = 30)
        
        Service.objects.create(area=self.area, 
                                name="Breakfast", 
                                description="3 course breakfast",
                                service_price=45,
                                vat_price=52)

    def test_create_valid_service(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)
        #self.assertEqual(response.data[0]['area'], self.area)
        #self.assertEqual(response.data[1]['name'], 'Breakfast')


    

