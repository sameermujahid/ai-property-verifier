import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_index_route(client):
    response = client.get('/')
    assert response.status_code == 200

def test_get_location_route(client):
    response = client.post('/get-location', json={
        'latitude': '19.0760',
        'longitude': '72.8777'
    })
    assert response.status_code == 200

def test_verify_route(client):
    response = client.post('/verify', data={
        'property_name': 'Test Property',
        'property_type': 'Apartment',
        'address': 'Test Address',
        'city': 'Mumbai',
        'state': 'Maharashtra'
    })
    assert response.status_code == 200 