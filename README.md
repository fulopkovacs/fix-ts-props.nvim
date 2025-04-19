# Nvim props

## notes

- patterns:

```
parameters > pattern
           > type
```

- DO not add missing prop names:
  - if the `rest` pattern is present

### NO missing prop names:

```ts
function hi({...props}: {prop1: string; prop2: boolean}) {
  return null
}

function hi2(person: {name: string; age: number}) {
  return null
}
```

### DO add missing props:
```ts
function hi_again({name, age} : {name: string, age: number}) {
  return null
}
```

## What should it do?

- should write the args from the type
- should work when I edit too

If I have a function

```tsx
function HelloPerson({name, age}: {name: string; age: number}) {
  return (
    <div>
      hello {name}! You are {age} years old.
    </div>
  )
}
```

When I write `{` as an argument of a function, it should be autocompleted
