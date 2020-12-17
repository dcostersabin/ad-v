# AD-V

__Platform Where You Watch And Share Ads To Get Pain__

``This is only the back-end implementation only written in ruby``

__Installation Process__

``
Make Sure You Have Ruby Installed On Your System.
``
*[install rvm](https://rvm.io/)*

__After installing rvm with rails__

``cd <into the project dit>``

``bundle install``


``rake db:setup ``

``rake db:migrate ``

``rails s ``

___

## Request Sample

``
curl --location --request POST 'localhost:3000//users' \
--data-raw '{
"user":
{
"name":"user123",
"email":"user123@example.com",
"password":"example123"
}
}``

__output__



```yaml

{
  "id": 6,
  "name": "user123",
  "email": "user123@example.com",
  "password_digest": "$2a$12$qfq.wd/uHZ44NJw/DQ7Pc.O2o2qS.iTbUlHH8DkqbMj2cKnaFzvLa",
  "user_type": 1,
  "validity": true,
  "created_at": "2020-12-17T13:05:25.375Z",
  "updated_at": "2020-12-17T13:05:25.375Z"
}
```

# Find Full Documentation On
__[Click Here](https://documenter.getpostman.com/view/13904156/TVsrG9eC#1c93eb17-dc2d-4076-a80e-f6d423c84308)__

____








