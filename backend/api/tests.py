from django.test import TestCase

from cabins.models import AreaCode, PostCode
from users.models import User


# Create your tests here.

class TestCabinApi(TestCase):

    def test_cabin_creation(self):
        """
        Tests that a cabin can be created.
        """
        owner = User.objects.create_user(username="owner", password="owner", email="email1@emai.fi")
        customer = User.objects.create_user(username="customer", password="customer", email="email@emai.fi")
        area = AreaCode.objects.create(area="Helsinki", post_code="00100")
        post = PostCode.objects.create(p_code=area, postal_district="Helsinki")

        data = {
            "name": "Test Cabin",
            "description": "Test Cabin",
            "price_per_night": 100,
            "area": area.id,
            "zip_code": post.id,
            "num_of_beds": 4,
        }

        response = self.client.post("/api/area/cabins/create", data)

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data["data"]["name"], data["name"])
        self.assertEqual(response.data["data"]["description"], data["description"])
        self.assertEqual(response.data["data"]["price_per_night"], format(float(data["price_per_night"]), ".2f"))
        self.assertEqual(response.data["data"]["area"], data["area"])
        self.assertEqual(response.data["data"]["zip_code"], data["zip_code"])
        self.assertEqual(response.data["data"]["num_of_beds"], data["num_of_beds"])


class TestAreaApi(TestCase):

    def test_area_creation(self):
        """
        Tests that an area can be created.
        """
        data = {
            "area": "Helsinki",
            "post_code": "00100",
        }

        response = self.client.post("/api/area/create", data)

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data["data"]["area"], data["area"])
        self.assertEqual(response.data["data"]["post_code"], data["post_code"])


class TestServicesApi(TestCase):

    def test_create_service(self):
        """
        Tests that a service can be created.
        """
        area = AreaCode.objects.create(area="Helsinki", post_code="00100")
        data = {
            "area": area.id,
            "name": "Sauna",
            "description": "Sauna",
            "service_price": 10,
            "vat_price": 2,
        }
        response = self.client.post("/api/area/services/create", data)
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data["data"]["area"], data["area"])
        self.assertEqual(response.data["data"]["name"], data["name"])
        self.assertEqual(response.data["data"]["description"], data["description"])
        self.assertEqual(response.data["data"]["service_price"], format(float(data["service_price"]), ".2f"))
        self.assertEqual(response.data["data"]["vat_price"], format(float(data["vat_price"]), ".2f"))
