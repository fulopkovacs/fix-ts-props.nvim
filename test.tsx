function HelloPerson({name, age}: {name: string, age: number}) {
  // @ts-ignore
  return <div>hello {name}! You are {age} years old.</div>
}

function sayHi(name: string) {
  return `Hi, ${name}!`
}

/*

    parameters: (formal_parameters ; [9, 19] - [9, 43]
      (required_parameter ; [9, 20] - [9, 42]
        pattern: (object_pattern ; [9, 20] - [9, 26]
          (shorthand_property_identifier_pattern)) ; [9, 21] - [9, 25]
        type: (type_annotation ; [9, 26] - [9, 42]
          (object_type ; [9, 28] - [9, 42]
            (property_signature ; [9, 29] - [9, 41]
              name: (property_identifier) ; [9, 29] - [9, 33]
              type: (type_annotation ; [9, 33] - [9, 41]
                (predefined_type))))))) ; [9, 35] - [9, 41]
*/
function sayHiAgain({name}: {name: string}) {
  return `Hi, again ${name}!`
}

const person: {name: string} = {name: 'hi'}

function sayHiAgain2(name, person: {age: number }, {hasCats} : {hasCats: boolean}, favColor?: string) {
  return `Hi, again ${name}! You are ${person.age} years old.${favColor ? ' Your fav color is ' + favColor + '.' : ''}`
}

function withSpread ({hello, ...props}: {hello: string, hi: boolean}) {
 return <div>hello</div> 
}

const {age, name: personName} = {name: "John", age: 30}

function hi ({hello, age, smile, age2, longlonglongPropertyName, longerPropertyName}: {hello: string, age: string, smile: boolean, age2: boolean, longlonglongPropertyName: string, longerPropertyName: string, exclusiveProp: string}) {
  // @ts-ignore
 return <div>{hello}</div>
}

function hiAgain(favColor: string, {person, friend}: {person:{age: number, hairColor: string}, friend: string}){
  return null
}

function test({}: {name: string}){ return true}
