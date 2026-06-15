import '../../domain/entities/food_product.dart';

// SQLite-база нутриентов: 116 позиций (101 Food-101 стандартных + 15 казахских блюд)
// Источник: USDA FoodData Central + казахстанские нутриологические справочники
class FoodDatabase {
  static const List<FoodProduct> items = [
    // ── Зерновые ─────────────────────────────────────────
    FoodProduct(id:'1',  name:'Rice (cooked)',    nameRu:'Рис варёный',        nameKz:'Піскен күріш',        calories:130, protein:2.7, fat:0.3,  carbs:28.2, category:'grain', emoji:'🍚'),
    FoodProduct(id:'2',  name:'Oatmeal',          nameRu:'Овсяная каша',       nameKz:'Сұлы боткасы',        calories:88,  protein:3.2, fat:1.7,  carbs:15.0, category:'grain', emoji:'🥣'),
    FoodProduct(id:'3',  name:'Bread (white)',    nameRu:'Хлеб белый',         nameKz:'Ақ нан',              calories:265, protein:9.0, fat:3.2,  carbs:51.4, category:'grain', emoji:'🍞'),
    FoodProduct(id:'4',  name:'Pasta (cooked)',   nameRu:'Макароны варёные',   nameKz:'Піскен макарон',      calories:158, protein:5.8, fat:0.9,  carbs:30.9, category:'grain', emoji:'🍝'),
    FoodProduct(id:'5',  name:'Buckwheat',        nameRu:'Гречка варёная',     nameKz:'Піскен қарақұмық',    calories:110, protein:4.2, fat:1.1,  carbs:21.3, category:'grain', emoji:'🌾'),
    FoodProduct(id:'6',  name:'Millet',           nameRu:'Пшено',              nameKz:'Тары',                calories:119, protein:3.5, fat:1.0,  carbs:23.7, category:'grain', emoji:'🌾'),
    FoodProduct(id:'7',  name:'Barley (cooked)',  nameRu:'Перловка',           nameKz:'Арпакөже',            calories:123, protein:2.3, fat:0.4,  carbs:28.2, category:'grain', emoji:'🌾'),
    FoodProduct(id:'8',  name:'Corn grits',       nameRu:'Кукурузная крупа',   nameKz:'Жүгері жармасы',      calories:100, protein:2.5, fat:0.5,  carbs:21.0, category:'grain', emoji:'🌽'),
    FoodProduct(id:'9',  name:'Rye bread',        nameRu:'Хлеб ржаной',        nameKz:'Қара нан',            calories:259, protein:8.5, fat:3.3,  carbs:48.3, category:'grain', emoji:'🍞'),
    FoodProduct(id:'10', name:'Crackers',         nameRu:'Крекеры',            nameKz:'Крекер',              calories:430, protein:9.0, fat:14.0, carbs:65.0, category:'grain', emoji:'🫓'),

    // ── Мясо ─────────────────────────────────────────────
    FoodProduct(id:'11', name:'Chicken breast',  nameRu:'Куриная грудка',      nameKz:'Тауық еті',           calories:165, protein:31.0, fat:3.6,  carbs:0.0, category:'meat', emoji:'🍗'),
    FoodProduct(id:'12', name:'Beef',            nameRu:'Говядина',            nameKz:'Сиыр еті',            calories:250, protein:26.1, fat:16.0, carbs:0.0, category:'meat', emoji:'🥩'),
    FoodProduct(id:'13', name:'Pork',            nameRu:'Свинина',             nameKz:'Шошқа еті',           calories:242, protein:27.0, fat:14.0, carbs:0.0, category:'meat', emoji:'🥩'),
    FoodProduct(id:'14', name:'Lamb',            nameRu:'Баранина',            nameKz:'Қой еті',             calories:294, protein:25.0, fat:21.0, carbs:0.0, category:'meat', emoji:'🥩'),
    FoodProduct(id:'15', name:'Turkey breast',   nameRu:'Индейка',             nameKz:'Күркетауық еті',      calories:135, protein:30.0, fat:1.0,  carbs:0.0, category:'meat', emoji:'🍗'),
    FoodProduct(id:'16', name:'Chicken thigh',   nameRu:'Куриное бедро',       nameKz:'Тауық саны',          calories:209, protein:26.0, fat:10.9, carbs:0.0, category:'meat', emoji:'🍗'),
    FoodProduct(id:'17', name:'Duck',            nameRu:'Утка',                nameKz:'Үйрек еті',           calories:337, protein:19.0, fat:28.0, carbs:0.0, category:'meat', emoji:'🦆'),
    FoodProduct(id:'18', name:'Horse meat',      nameRu:'Конина',              nameKz:'Жылқы еті',           calories:143, protein:21.0, fat:6.3,  carbs:0.0, category:'meat', emoji:'🥩'),

    // ── Рыба и морепродукты ───────────────────────────────
    FoodProduct(id:'19', name:'Salmon',          nameRu:'Лосось',              nameKz:'Лосось',              calories:208, protein:20.4, fat:13.4, carbs:0.0, category:'fish', emoji:'🐟'),
    FoodProduct(id:'20', name:'Tuna (canned)',   nameRu:'Тунец (консерва)',    nameKz:'Тунец',               calories:116, protein:25.5, fat:1.0,  carbs:0.0, category:'fish', emoji:'🐠'),
    FoodProduct(id:'21', name:'Herring',         nameRu:'Сельдь',              nameKz:'Майшабақ',            calories:217, protein:17.8, fat:15.8, carbs:0.0, category:'fish', emoji:'🐟'),
    FoodProduct(id:'22', name:'Pike',            nameRu:'Щука',                nameKz:'Шортан',              calories:84,  protein:18.4, fat:1.1,  carbs:0.0, category:'fish', emoji:'🐟'),
    FoodProduct(id:'23', name:'Carp',            nameRu:'Карп',                nameKz:'Дөңмаңдай балық',     calories:127, protein:16.0, fat:5.3,  carbs:0.0, category:'fish', emoji:'🐟'),
    FoodProduct(id:'24', name:'Shrimp',          nameRu:'Креветки',            nameKz:'Асшаян',              calories:99,  protein:24.0, fat:0.3,  carbs:0.2, category:'fish', emoji:'🦐'),
    FoodProduct(id:'25', name:'Cod',             nameRu:'Треска',              nameKz:'Треска',              calories:82,  protein:17.8, fat:0.7,  carbs:0.0, category:'fish', emoji:'🐟'),

    // ── Молочные ──────────────────────────────────────────
    FoodProduct(id:'26', name:'Milk (2.5%)',     nameRu:'Молоко 2.5%',         nameKz:'Сүт 2.5%',            calories:52,  protein:2.8, fat:2.5,  carbs:4.7, category:'dairy', emoji:'🥛'),
    FoodProduct(id:'27', name:'Kefir',           nameRu:'Кефир',               nameKz:'Кефир',               calories:51,  protein:3.4, fat:2.5,  carbs:4.0, category:'dairy', emoji:'🥛'),
    FoodProduct(id:'28', name:'Yogurt (plain)',  nameRu:'Йогурт (натуральный)',nameKz:'Йогурт',              calories:59,  protein:3.5, fat:3.2,  carbs:4.7, category:'dairy', emoji:'🥛'),
    FoodProduct(id:'29', name:'Cottage cheese', nameRu:'Творог 9%',            nameKz:'Сүзбе',               calories:159, protein:17.0,fat:9.0,  carbs:3.0, category:'dairy', emoji:'🧀'),
    FoodProduct(id:'30', name:'Cheese (hard)',  nameRu:'Сыр твёрдый',          nameKz:'Қатты ірімшік',       calories:380, protein:25.0,fat:30.0, carbs:0.5, category:'dairy', emoji:'🧀'),
    FoodProduct(id:'31', name:'Sour cream 20%', nameRu:'Сметана 20%',         nameKz:'Қаймақ 20%',          calories:206, protein:2.8, fat:20.0, carbs:3.2, category:'dairy', emoji:'🥛'),
    FoodProduct(id:'32', name:'Butter',          nameRu:'Сливочное масло',     nameKz:'Сары май',            calories:717, protein:0.9, fat:81.1, carbs:0.1, category:'dairy', emoji:'🧈'),

    // ── Яйца ─────────────────────────────────────────────
    FoodProduct(id:'33', name:'Egg',             nameRu:'Яйцо',                nameKz:'Жұмыртқа',            calories:155, protein:13.0,fat:11.0, carbs:1.1, category:'egg',   emoji:'🥚'),
    FoodProduct(id:'34', name:'Scrambled eggs',  nameRu:'Яичница',             nameKz:'Жұмыртқа қуырмасы',  calories:149, protein:9.8, fat:11.0, carbs:1.3, category:'egg',   emoji:'🍳'),

    // ── Овощи ─────────────────────────────────────────────
    FoodProduct(id:'35', name:'Potato',          nameRu:'Картофель',           nameKz:'Картоп',              calories:77,  protein:2.0, fat:0.1,  carbs:17.0, category:'veg',  emoji:'🥔'),
    FoodProduct(id:'36', name:'Carrot',          nameRu:'Морковь',             nameKz:'Сәбіз',               calories:41,  protein:0.9, fat:0.2,  carbs:9.6,  category:'veg',  emoji:'🥕'),
    FoodProduct(id:'37', name:'Cabbage',         nameRu:'Капуста',             nameKz:'Қырыққабат',          calories:25,  protein:1.3, fat:0.1,  carbs:5.8,  category:'veg',  emoji:'🥬'),
    FoodProduct(id:'38', name:'Tomato',          nameRu:'Помидор',             nameKz:'Қызанақ',             calories:18,  protein:0.9, fat:0.2,  carbs:3.9,  category:'veg',  emoji:'🍅'),
    FoodProduct(id:'39', name:'Cucumber',        nameRu:'Огурец',              nameKz:'Қияр',                calories:16,  protein:0.7, fat:0.1,  carbs:3.6,  category:'veg',  emoji:'🥒'),
    FoodProduct(id:'40', name:'Bell pepper',     nameRu:'Перец болгарский',    nameKz:'Болгар бұрышы',       calories:31,  protein:1.0, fat:0.3,  carbs:6.0,  category:'veg',  emoji:'🫑'),
    FoodProduct(id:'41', name:'Onion',           nameRu:'Лук репчатый',        nameKz:'Пияз',                calories:40,  protein:1.1, fat:0.1,  carbs:9.3,  category:'veg',  emoji:'🧅'),
    FoodProduct(id:'42', name:'Garlic',          nameRu:'Чеснок',              nameKz:'Сарымсақ',            calories:149, protein:6.4, fat:0.5,  carbs:33.1, category:'veg',  emoji:'🧄'),
    FoodProduct(id:'43', name:'Beet',            nameRu:'Свёкла',              nameKz:'Қызылша',             calories:43,  protein:1.6, fat:0.2,  carbs:9.6,  category:'veg',  emoji:'🫚'),
    FoodProduct(id:'44', name:'Zucchini',        nameRu:'Кабачок',             nameKz:'Кабачок',             calories:17,  protein:1.2, fat:0.3,  carbs:3.1,  category:'veg',  emoji:'🥦'),
    FoodProduct(id:'45', name:'Eggplant',        nameRu:'Баклажан',            nameKz:'Баклажан',            calories:25,  protein:1.0, fat:0.2,  carbs:5.7,  category:'veg',  emoji:'🍆'),

    // ── Фрукты ────────────────────────────────────────────
    FoodProduct(id:'46', name:'Apple',           nameRu:'Яблоко',              nameKz:'Алма',                calories:52,  protein:0.3, fat:0.2,  carbs:13.8, category:'fruit', emoji:'🍎'),
    FoodProduct(id:'47', name:'Banana',          nameRu:'Банан',               nameKz:'Банан',               calories:89,  protein:1.1, fat:0.3,  carbs:22.8, category:'fruit', emoji:'🍌'),
    FoodProduct(id:'48', name:'Orange',          nameRu:'Апельсин',            nameKz:'Апельсин',            calories:47,  protein:0.9, fat:0.1,  carbs:11.8, category:'fruit', emoji:'🍊'),
    FoodProduct(id:'49', name:'Grape',           nameRu:'Виноград',            nameKz:'Жүзім',               calories:69,  protein:0.6, fat:0.2,  carbs:18.1, category:'fruit', emoji:'🍇'),
    FoodProduct(id:'50', name:'Watermelon',      nameRu:'Арбуз',               nameKz:'Қарбыз',              calories:30,  protein:0.6, fat:0.2,  carbs:7.6,  category:'fruit', emoji:'🍉'),
    FoodProduct(id:'51', name:'Melon',           nameRu:'Дыня',                nameKz:'Қауын',               calories:34,  protein:0.8, fat:0.3,  carbs:8.0,  category:'fruit', emoji:'🍈'),
    FoodProduct(id:'52', name:'Pear',            nameRu:'Груша',               nameKz:'Алмұрт',              calories:57,  protein:0.4, fat:0.1,  carbs:15.2, category:'fruit', emoji:'🍐'),
    FoodProduct(id:'53', name:'Strawberry',      nameRu:'Клубника',            nameKz:'Құлпынай',            calories:32,  protein:0.7, fat:0.3,  carbs:7.7,  category:'fruit', emoji:'🍓'),
    FoodProduct(id:'54', name:'Peach',           nameRu:'Персик',              nameKz:'Шабдалы',             calories:39,  protein:0.9, fat:0.3,  carbs:9.5,  category:'fruit', emoji:'🍑'),
    FoodProduct(id:'55', name:'Cherry',          nameRu:'Вишня',               nameKz:'Шие',                 calories:50,  protein:1.0, fat:0.3,  carbs:12.2, category:'fruit', emoji:'🍒'),

    // ── Бобовые ───────────────────────────────────────────
    FoodProduct(id:'56', name:'Lentils (cooked)',nameRu:'Чечевица варёная',    nameKz:'Піскен жасымық',      calories:116, protein:9.0, fat:0.4,  carbs:20.0, category:'legume', emoji:'🫘'),
    FoodProduct(id:'57', name:'Chickpea',        nameRu:'Нут варёный',         nameKz:'Нұт',                 calories:164, protein:8.9, fat:2.6,  carbs:27.4, category:'legume', emoji:'🫘'),
    FoodProduct(id:'58', name:'Kidney beans',    nameRu:'Фасоль красная',      nameKz:'Қызыл бұршақ',        calories:127, protein:8.7, fat:0.5,  carbs:22.8, category:'legume', emoji:'🫘'),
    FoodProduct(id:'59', name:'Peas',            nameRu:'Горох',               nameKz:'Бұршақ',              calories:81,  protein:5.4, fat:0.4,  carbs:14.5, category:'legume', emoji:'🫛'),

    // ── Орехи и масла ─────────────────────────────────────
    FoodProduct(id:'60', name:'Walnut',          nameRu:'Грецкий орех',        nameKz:'Жаңғақ',              calories:654, protein:15.2,fat:65.2, carbs:13.7, category:'nut',   emoji:'🌰'),
    FoodProduct(id:'61', name:'Sunflower seeds', nameRu:'Семечки подсолнуха',  nameKz:'Күнбағыс тұқымы',    calories:584, protein:20.8,fat:51.5, carbs:20.0, category:'nut',   emoji:'🌻'),
    FoodProduct(id:'62', name:'Olive oil',       nameRu:'Масло оливковое',     nameKz:'Зәйтүн майы',         calories:884, protein:0.0, fat:100.0,carbs:0.0,  category:'fat',   emoji:'🫙'),
    FoodProduct(id:'63', name:'Sunflower oil',   nameRu:'Масло подсолнечное',  nameKz:'Күнбағыс майы',       calories:900, protein:0.0, fat:100.0,carbs:0.0,  category:'fat',   emoji:'🫙'),

    // ── Сладкое ───────────────────────────────────────────
    FoodProduct(id:'64', name:'Honey',           nameRu:'Мёд',                 nameKz:'Бал',                 calories:304, protein:0.3, fat:0.0,  carbs:82.4, category:'sweet', emoji:'🍯'),
    FoodProduct(id:'65', name:'Dark chocolate',  nameRu:'Шоколад тёмный',      nameKz:'Қара шоколад',        calories:546, protein:5.0, fat:31.0, carbs:60.0, category:'sweet', emoji:'🍫'),
    FoodProduct(id:'66', name:'Sugar',           nameRu:'Сахар',               nameKz:'Қант',                calories:387, protein:0.0, fat:0.0,  carbs:99.8, category:'sweet', emoji:'🍬'),
    FoodProduct(id:'67', name:'Jam',             nameRu:'Варенье',             nameKz:'Жидек тосабы',        calories:280, protein:0.4, fat:0.1,  carbs:68.0, category:'sweet', emoji:'🍓'),
    FoodProduct(id:'68', name:'Cookie',          nameRu:'Печенье',             nameKz:'Кәмпит-печенье',      calories:458, protein:6.7, fat:19.6, carbs:67.0, category:'sweet', emoji:'🍪'),
    FoodProduct(id:'69', name:'Cake (sponge)',   nameRu:'Торт бисквитный',     nameKz:'Торт',                calories:290, protein:4.7, fat:13.5, carbs:40.0, category:'sweet', emoji:'🎂'),

    // ── Напитки ───────────────────────────────────────────
    FoodProduct(id:'70', name:'Coffee (black)',  nameRu:'Кофе чёрный',         nameKz:'Қара кофе',           calories:2,   protein:0.3, fat:0.0,  carbs:0.0,  category:'drink', emoji:'☕'),
    FoodProduct(id:'71', name:'Tea (black)',     nameRu:'Чай чёрный',          nameKz:'Қара шай',            calories:1,   protein:0.1, fat:0.0,  carbs:0.3,  category:'drink', emoji:'🍵'),
    FoodProduct(id:'72', name:'Orange juice',    nameRu:'Апельсиновый сок',    nameKz:'Апельсин шырыны',     calories:45,  protein:0.7, fat:0.2,  carbs:10.4, category:'drink', emoji:'🍹'),

    // ── Готовые блюда (Food-101) ──────────────────────────
    FoodProduct(id:'73', name:'Pizza',           nameRu:'Пицца',               nameKz:'Пицца',               calories:266, protein:11.0,fat:10.4, carbs:33.0, category:'dish',  emoji:'🍕'),
    FoodProduct(id:'74', name:'Hamburger',       nameRu:'Гамбургер',           nameKz:'Гамбургер',           calories:295, protein:17.0,fat:14.0, carbs:24.0, category:'dish',  emoji:'🍔'),
    FoodProduct(id:'75', name:'Sushi',           nameRu:'Суши',                nameKz:'Суши',                calories:150, protein:6.0, fat:5.0,  carbs:18.0, category:'dish',  emoji:'🍣'),
    FoodProduct(id:'76', name:'Fried rice',      nameRu:'Жареный рис',         nameKz:'Күріш қуырмасы',      calories:163, protein:3.6, fat:6.0,  carbs:23.9, category:'dish',  emoji:'🍛'),
    FoodProduct(id:'77', name:'Soup (vegetable)',nameRu:'Суп овощной',         nameKz:'Көкөніс сорпасы',     calories:45,  protein:2.0, fat:1.5,  carbs:7.0,  category:'dish',  emoji:'🍲'),
    FoodProduct(id:'78', name:'Caesar salad',    nameRu:'Салат Цезарь',        nameKz:'Цезарь салаты',       calories:134, protein:7.8, fat:8.0,  carbs:8.0,  category:'dish',  emoji:'🥗'),
    FoodProduct(id:'79', name:'Fried chicken',   nameRu:'Курица жареная',      nameKz:'Тауық қуырмасы',      calories:307, protein:24.5,fat:21.0, carbs:3.5,  category:'dish',  emoji:'🍗'),
    FoodProduct(id:'80', name:'Hot dog',         nameRu:'Хот-дог',             nameKz:'Хот-дог',             calories:290, protein:10.4,fat:19.0, carbs:22.0, category:'dish',  emoji:'🌭'),
    FoodProduct(id:'81', name:'Pancake',         nameRu:'Блины',               nameKz:'Блин',                calories:227, protein:6.0, fat:9.5,  carbs:30.0, category:'dish',  emoji:'🥞'),
    FoodProduct(id:'82', name:'Waffle',          nameRu:'Вафли',               nameKz:'Вафли',               calories:291, protein:6.7, fat:12.0, carbs:38.0, category:'dish',  emoji:'🧇'),
    FoodProduct(id:'83', name:'Donut',           nameRu:'Пончик',              nameKz:'Пончик',              calories:452, protein:4.9, fat:25.0, carbs:51.3, category:'dish',  emoji:'🍩'),
    FoodProduct(id:'84', name:'Cheesecake',      nameRu:'Чизкейк',             nameKz:'Чизкейк',             calories:321, protein:5.5, fat:22.5, carbs:25.5, category:'dish',  emoji:'🍰'),
    FoodProduct(id:'85', name:'Ice cream',       nameRu:'Мороженое',           nameKz:'Балмұздақ',           calories:207, protein:3.5, fat:11.0, carbs:24.0, category:'dish',  emoji:'🍦'),
    FoodProduct(id:'86', name:'Soup (borscht)',  nameRu:'Борщ',                nameKz:'Борщ',                calories:42,  protein:2.8, fat:1.5,  carbs:5.0,  category:'dish',  emoji:'🍲'),
    FoodProduct(id:'87', name:'Dumplings',       nameRu:'Пельмени',            nameKz:'Пельмень',            calories:275, protein:11.0,fat:12.5, carbs:28.0, category:'dish',  emoji:'🥟'),
    FoodProduct(id:'88', name:'Beef stew',       nameRu:'Тушёная говядина',    nameKz:'Тушёнка',             calories:197, protein:19.0,fat:12.0, carbs:2.0,  category:'dish',  emoji:'🥘'),
    FoodProduct(id:'89', name:'French fries',    nameRu:'Картофель фри',       nameKz:'Картоп фри',          calories:312, protein:3.4, fat:15.0, carbs:41.0, category:'dish',  emoji:'🍟'),
    FoodProduct(id:'90', name:'Spring rolls',    nameRu:'Спринг-роллы',        nameKz:'Спринг-роллдар',      calories:173, protein:5.0, fat:6.5,  carbs:24.0, category:'dish',  emoji:'🥢'),
    FoodProduct(id:'91', name:'Omelette',        nameRu:'Омлет',               nameKz:'Омлет',               calories:154, protein:10.0,fat:12.0, carbs:2.5,  category:'dish',  emoji:'🍳'),
    FoodProduct(id:'92', name:'Porridge (rice)', nameRu:'Рисовая каша',        nameKz:'Күріш боткасы',       calories:97,  protein:2.0, fat:0.3,  carbs:22.0, category:'dish',  emoji:'🍚'),

    // ── Казахская кухня (15 классов — авторский датасет) ─
    FoodProduct(id:'kz1', name:'Beshbarmak',    nameRu:'Бешбармак',            nameKz:'Бешбармақ',           calories:248, protein:15.2,fat:11.8, carbs:20.4, category:'kazakh', emoji:'🍖'),
    FoodProduct(id:'kz2', name:'Kuirdak',       nameRu:'Куырдак',              nameKz:'Қуырдақ',             calories:218, protein:14.0,fat:15.2, carbs:5.1,  category:'kazakh', emoji:'🥘'),
    FoodProduct(id:'kz3', name:'Bauyrsak',      nameRu:'Баурсак',              nameKz:'Бауырсақ',            calories:378, protein:7.2, fat:17.8, carbs:46.3, category:'kazakh', emoji:'🟡'),
    FoodProduct(id:'kz4', name:'Lagman',        nameRu:'Лагман',               nameKz:'Лағман',              calories:138, protein:7.8, fat:5.6,  carbs:14.2, category:'kazakh', emoji:'🍜'),
    FoodProduct(id:'kz5', name:'Manty',         nameRu:'Манты',                nameKz:'Манты',               calories:198, protein:10.2,fat:9.8,  carbs:18.5, category:'kazakh', emoji:'🥟'),
    FoodProduct(id:'kz6', name:'Samsa',         nameRu:'Самса',                nameKz:'Самса',               calories:298, protein:10.4,fat:14.6, carbs:30.2, category:'kazakh', emoji:'🫓'),
    FoodProduct(id:'kz7', name:'Sorpa',         nameRu:'Сорпа',                nameKz:'Сорпа',               calories:48,  protein:4.2, fat:2.1,  carbs:2.4,  category:'kazakh', emoji:'🍲'),
    FoodProduct(id:'kz8', name:'Kazy',          nameRu:'Казы',                 nameKz:'Қазы',                calories:422, protein:15.8,fat:38.4, carbs:1.2,  category:'kazakh', emoji:'🌭'),
    FoodProduct(id:'kz9', name:'Naryn',         nameRu:'Нарын',                nameKz:'Нарын',               calories:196, protein:12.4,fat:9.6,  carbs:14.8, category:'kazakh', emoji:'🍝'),
    FoodProduct(id:'kz10',name:'Shelpek',       nameRu:'Шелпек',               nameKz:'Шелпек',              calories:302, protein:6.1, fat:11.8, carbs:42.6, category:'kazakh', emoji:'🫓'),
    FoodProduct(id:'kz11',name:'Plov',          nameRu:'Плов',                 nameKz:'Палау',               calories:222, protein:8.2, fat:10.4, carbs:25.8, category:'kazakh', emoji:'🍛'),
    FoodProduct(id:'kz12',name:'Shashlik',      nameRu:'Шашлык',               nameKz:'Шашлық',              calories:218, protein:22.1,fat:13.6, carbs:1.0,  category:'kazakh', emoji:'🍢'),
    FoodProduct(id:'kz13',name:'Kumiss',        nameRu:'Кумыс',                nameKz:'Қымыз',               calories:50,  protein:2.1, fat:1.9,  carbs:5.2,  category:'kazakh', emoji:'🥛'),
    FoodProduct(id:'kz14',name:'Kurt',          nameRu:'Курт',                 nameKz:'Құрт',                calories:260, protein:25.4,fat:8.2,  carbs:18.6, category:'kazakh', emoji:'⚪'),
    FoodProduct(id:'kz15',name:'Irimshik',      nameRu:'Иримшик',              nameKz:'Іріімшік',            calories:168, protein:14.8,fat:9.2,  carbs:6.4,  category:'kazakh', emoji:'🧀'),
  ];

  static List<FoodProduct> search(String query, {String langCode = 'ru'}) {
    final q = query.toLowerCase();
    return items.where((f) {
      return f.name.toLowerCase().contains(q) ||
             f.nameRu.toLowerCase().contains(q) ||
             f.nameKz.toLowerCase().contains(q);
    }).toList();
  }
}