from django.test import TestCase
from .models import Cabin, Area, PostCode

class CabinModelTest(TestCase):

    """
    Tests to ensure that our model behaves correctly.
    """

    @classmethod
    def setUp(cls):
        # Sets up non-modified objects used by every test method
        area = Area.objects.create(area="Test Area 51")
        post_code = PostCode.objects.create(p_code="66669", postal_district="Test Postal District 9")
        Cabin.objects.create(name="Test Cabin in the woods", description="Test Description", price_per_night=100, area=area,
                            zip_code=post_code, num_of_beds=2)
        
    # Tests field labels (names)
    def test_name_label(self):
        cabin = Cabin.objects.get(id=1)
        field_label = cabin._meta.get_field('name').verbose_name
        self.assertEqual(field_label, 'name')

    # Test max length of the description field
    def test_description_max_length(self):
        cabin = Cabin.objects.get(id=1)
        max_length = cabin._meta.get_field('description').max_length
        self.assertEqual(max_length, 255)

    # Test max number of digits in the price_per_night field
    def test_price_per_night_max_digits(self):
        cabin = Cabin.objects.get(id=1)
        max_digits = cabin._meta.get_field('price_per_night').max_digits
        self.assertEqual(max_digits, 8)

    # Test Foreign Key relationships to Area and PostCode models
    def test_area_foreign_key(self):
        cabin = Cabin.objects.get(id=1)
        area = Area.objects.get(area="Test Area 51")
        self.assertEqual(cabin.area, area)

    # Test the number of beds in the cabin
    def test_num_of_beds(self):
        cabin = Cabin.objects.get(id=1)
        self.assertEqual(cabin.num_of_beds, 2)

    # Test address field being nullable
    def test_address_null(self):
        cabin = Cabin.objects.get(id=1)
        self.assertIsNone(cabin.address)

    # Test the __str__ method of the Cabin model
    def test_str_method(self):
        cabin = Cabin.objects.get(id=1)
        self.assertEqual(str(cabin), 'Test Cabin in the woods')