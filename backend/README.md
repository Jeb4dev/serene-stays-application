# Backend

Django REST API is used as project backend.
It handles all the requests from the frontend and communicates with the database and external APIs like oauth2.

## Setup

### Requirements

- Python 3.9

### Installation

1. Create a virtual environment and activate it
2. Install the requirements with `pip install -r requirements.txt`
3. Run the migrations with `python manage.py migrate`
4. Create Django Super User with `python manage.py createsuperuser`
5. Run the server with `python manage.py runserver`

## Development

### Formatting

``python.exe -m black **/*.py --line-length 120``

## API

### Endpoints

Warning: This list is not complete!

- `/api/user/login/` - Login user with username and password
- `/api/user/logout/` - Logout user with token
- `/api/user/register/` - Register user with username, email and password and optional other fields
- `/api/user` - Get personal details with token
- `/api/user?username=<username>` - Get user details by username, admin only
- `/api/user/update/` - Update user details with optional fields and token

- `/api/area/` - Get all areas
- `/api/area?area=<name>` - Get area by name
- `/api/area/create/` - Create area with name and optional fields, admin only
- `/api/area/update?area=<name>` - Update area by name, admin only
- `/api/area/delete?area=<name>` - Delete area by name, admin only

- `/api/area/cabin/` - Get all cabins
- `/api/area/cabin?cabin=<name>` - Get cabin by name
- `/api/area/cabin/create/` - Create cabin with name and optional fields, auth required
- `/api/area/cabin/update?cabin=<name>` - Update cabin by name, owner and admin only
- `/api/area/cabin/delete?cabin=<name>` - Delete cabin by name, owner and admin only

- `/api/area/service/` - Get all services
- `/api/area/service?service=<name>` - Get service by name
- `/api/area/service/create/` - Create service with name and optional fields, admin only
- `/api/area/service/update?service=<name>` - Update service by name, admin only
- `/api/area/service/delete?service=<name>` - Delete service by name, admin only

- `/api/reservation/` - Get all reservations, customer and owner can get only their own reservations, admin can get all
- `/api/reservation?reservation=<id>` - Get reservation by id, access: customer and owner (limited), admin (all)
- `/api/reservation/create/` - Create reservation, auth required
- `/api/reservation/update?reservation=<id>` - Update reservation by id, admin only
- `/api/reservation/delete?reservation=<id>` - Delete reservation by id, admin only
- `/api/reservation/confirm?reservation=<id>` - Confirm reservation by id, admin only
- `/api/reservation/cancel?reservation=<id>` - Cancel reservation by id

- `/api/invoice/` - Get all invoices, customer and owner can get only their own invoices, admin can get all
- `/api/invoice?invoice=<id>` - Get invoice by id, access: customer and owner (limited), admin (all)
- `/api/invoice/create/` - Create invoice, auth required
- `/api/invoice/update?invoice=<id>` - Update invoice by id, admin only
- `/api/invoice/delete?invoice=<id>` - Delete invoice by id, admin only


## Tests

To run the tests, run `python manage.py test`.

Additionally, you can only run specific test with `python manage.py test <collection>`


## License

This project is licensed under the [GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/) License.

## Resources

- [Django REST Framework](https://www.django-rest-framework.org/)
- [Django](https://www.djangoproject.com/)
- [Django OAuth Toolkit](https://django-oauth-toolkit.readthedocs.io/en/latest/)
