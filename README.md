# openmessages.info

[openmessages.info](https://openmessages.info) gives an outlet for users to openly convey their thoughts, feelings, & ideas
on the web. It is a platform were anybody can signup and start producing meaningful content
to share with friends, family, & the world.

You can test out the service with demo user credentials but make no promises about data retention

username - ```jonhdoe```

password - ```johndoe1```

## API Usage

To get a single message by uuid
```
message/get/uuid
```
To get all messages authored by a certain user
```
message/user/username
```
To delete a single message by uuid
```
message/delete?uuid=uuid&username=username&password=password
```
To put a single message
```
message/put?username=username&password=password&textarea=message
```
To signup
```
message/signup?username=username&password=password
```

## Contributing

```
1. Fork it ( https://github.com/rangeroob/openmessages.info/fork )
2. Clone your repo (`git clone https://github.com/[yourusername]/openmessages.info`)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
```

## Running the tests

```
rake test
```

## Built With

* [bcrypt](https://github.com/codahale/bcrypt-ruby) - The password hashing function used
* [cuba](https://github.com/soveran/cuba) - The webframework used
* [kramdown](https://github.com/gettalong/kramdown) - The markdown parser used
* [password_blacklist](https://github.com/gchan/password_blacklist) - The password checker used
* [sequel](https://github.com/jeremyevans/sequel) - The ORM used
* [sqlite3](https://github.com/sparklemotion/sqlite3-ruby) - The database used

## License

This project is licensed under the MPL License - see the [LICENSE.txt](LICENSE.txt) file for details
