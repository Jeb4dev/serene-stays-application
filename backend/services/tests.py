from decimal import Decimal
from rest_framework import status
from rest_framework.test import APITestCase
from .models import Service
from cabins.models import Cabin, Area, PostCode


class ServiceTests(APITestCase):
    """
    Test the Service model. Creates a Service object and tests that its
    attributes match the values we set in the 'setUp' method. The
    'test_service_creation checks that the 'Service' object was created
    successfully, and the other methods check that each attribute is set
    correctly.
    """
    def setUp(self):
        self.area=Area.objects.create(area="Helsinki")
        #self.post=PostCode.objects.create(p_code='00070', postal_district="Helsinki")
        self.service = Service.objects.create(
            area=self.area,
            name="Sauna 66",
            description="Sauna 66 description",
            service_price=Decimal("25.00"),
            vat_price=Decimal("30.00")
        )

    def test_service_creation(self):
        service_count = Service.objects.count()
        self.assertEqual(service_count, 1)

    def test_service_area(self):
        self.assertEqual(self.service.area, self.area)

    def test_service_name(self):
        self.assertEqual(self.service.name, "Sauna 66")
    
    def test_service_description(self):
        self.assertEqual(self.service.description, "Sauna 66 description")

    def test_service_price(self):
        self.assertEqual(self.service.service_price, Decimal("25.00"))

    def test_service_vat_price(self):
        self.assertEqual(self.service.vat_price, Decimal("30.00"))


    

