from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from .models import Service
from cabins.models import Cabin, Area, PostCode


class ServiceTests(APITestCase):
    """Test the Service model"""
    def setUp(self):
        self.url=reverse('create_service')
        self.area=Area.objects.create(area="Helsinki")
        #self.post=PostCode.objects.create(p_code='00070', postal_district="Helsinki")
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

    """ def test_create_valid_service(self):
        data = self.valid_service
        print(self.valid_service)
        response = self.client.post(self.url, data)
        print(response.data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)
        self.assertEqual(response.data[0]['area'], self.area)
        self.assertEqual(response.data[1]['name'], 'Breakfast') """


    

