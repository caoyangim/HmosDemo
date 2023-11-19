import { LazyDataSource } from '../module/calendar/viewmodel/LazyDataSource'

@Observed
class Person {
  constructor(private _name: string,
              private _age: number) {
  }

  get name() {
    return this._name
  }

  get age() {
    return this._age
  }

  set age(age: number) {
    this.age = age
  }

  ageAdd() {
    this._age++
  }
}

@Component
struct PersonView {
  @ObjectLink person: Person;
  costOfOneAttempt: number = 1;

  build() {
    Column() {
      Text("name:" + this.person.name)
      Text("age:" + this.person.age)
      // @Prop装饰的变量不会同步给父组件
      Button(`内部控件操作age++`).onClick(() => {
        this.person.ageAdd()
      })
    }
  }
}

@Entry
@Component
struct ParentComponent {
  @State _personList: LazyDataSource<Person> = new LazyDataSource();

  aboutToAppear() {
    this._personList.pushData(new Person("Tom", 12))
    this._personList.pushData(new Person("Jerry", 14))
  }

  build() {
    Column() {
      LazyForEach(this._personList, (personItem: Person, index) => {
        PersonView({ person: personItem })
      })
      Button("外部控件age add").onClick(() => {
        this._personList.getData(0).ageAdd()
      })
    }

  }
}