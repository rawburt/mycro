# Mycro

A micro framework for service layer code.

## Mycro::Result

`Mycro::Result` is to be used to return values from service layer operations.

```ruby
result = Mycro::Result::Ok("my result")

result.ok? # => true
result.error? # => false
result.get_ok # => "my result"
result.get_error # raises Mycro::Result::WrongResultError

result = Mycro::Result::Error("oopsies")

result.ok? # => false
result.error? # => true
result.get_ok # => raises Mycro::Result::WrongResultError
result.get_error # => "oopsies"
```

Example service layer operation:

```ruby
class ValidateUser
  include Mycro::Result

  def call(params)
    return Error("name is too short") if params[:name].size <> 4
    return Error("name is too long") if params[:name].size > 30
    return Error("name is bad format") unless params[:name] =~ /^[a-zA-Z0-9\-_]+$/

    Ok(params[:name])
  end
end
```

The benefit of `Mycro::Result` is consistent service layer object responses.

## Mycro::Registry

`Mycro::Registry` is to be used as an object registry.

```ruby
class SomeService
  # service code...
end

Mycro::Registry.register(:some_service, SomeService.new)

class SomeOtherService
  include Mycro::Registry::Import[:some_service]

  def call(params)
    result = some_service.call

    if result.ok?
      # do some work
    else
      # oops
    end
  end
end
```

The benefit of `Mycro::Registry` is simple dependency injection.

## Other

Special thanks to various inspiration:
* https://github.com/collectiveidea/interactor
* https://dry-rb.org/gems/dry-monads
* https://dry-rb.org/gems/dry-auto_inject
* https://github.com/trailblazer/trailblazer
