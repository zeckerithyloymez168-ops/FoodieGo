/**
 * Seeds FoodieGo menu data into Firestore using the logged-in Firebase CLI token.
 *
 * Usage (from food_order_app/):
 *   node tool/seed_foodiego.mjs
 *
 * Writes to database "FoodieGo" if it exists, otherwise "(default)".
 */

import fs from 'fs';
import https from 'https';
import http from 'http';
import path from 'path';
import os from 'os';
import { fileURLToPath } from 'url';

const PROJECT_ID = 'foodiego-f2abf';
// Firebase named DB ids must match /[a-z][a-z0-9-]*/ (no capitals)
const PREFERRED_DB = 'foodiego';
const DEFAULT_DB = '(default)';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const FOODS = [
  {
    "id": "pepperoni",
    "name": "Pepperoni",
    "description": "Classic wood-fired pizza with spicy pepperoni, mozzarella, and house tomato sauce.",
    "price": 14.5,
    "rating": 4.9,
    "time": "20 min",
    "kcal": "780 Kcal",
    "category": "Pizza",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 842,
    "ingredients": [
      "Pepperoni",
      "Mozzarella",
      "Tomato",
      "Oregano"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500&q=85"
  },
  {
    "id": "margherita",
    "name": "Margherita",
    "description": "San Marzano tomato, fresh mozzarella, basil, and olive oil.",
    "price": 12,
    "rating": 4.8,
    "time": "18 min",
    "kcal": "640 Kcal",
    "category": "Pizza",
    "isPopular": true,
    "isVeg": true,
    "reviewCount": 620,
    "ingredients": [
      "Tomato",
      "Mozzarella",
      "Basil",
      "Olive oil"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500&q=85"
  },
  {
    "id": "bbq",
    "name": "BBQ Chicken",
    "description": "Smoky BBQ sauce, grilled chicken, red onion, and cheddar.",
    "price": 15.5,
    "rating": 4.7,
    "time": "22 min",
    "kcal": "820 Kcal",
    "category": "Pizza",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 410,
    "ingredients": [
      "Chicken",
      "BBQ sauce",
      "Onion",
      "Cheddar"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&q=85"
  },
  {
    "id": "truffle",
    "name": "Truffle Mushroom",
    "description": "Wild mushrooms, truffle oil, mozzarella, and thyme.",
    "price": 17,
    "rating": 4.9,
    "time": "24 min",
    "kcal": "710 Kcal",
    "category": "Pizza",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 288,
    "ingredients": [
      "Mushroom",
      "Truffle oil",
      "Mozzarella",
      "Thyme"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=500&q=85"
  },
  {
    "id": "veggie",
    "name": "Garden Veggie",
    "description": "Peppers, olives, onion, corn, and light mozzarella.",
    "price": 13.5,
    "rating": 4.6,
    "time": "18 min",
    "kcal": "590 Kcal",
    "category": "Pizza",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 195,
    "ingredients": [
      "Pepper",
      "Olive",
      "Onion",
      "Corn"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?w=500&q=85"
  },
  {
    "id": "four-cheese",
    "name": "Four Cheese",
    "description": "Mozzarella, gorgonzola, parmesan, and fontina blend.",
    "price": 15,
    "rating": 4.8,
    "time": "20 min",
    "kcal": "850 Kcal",
    "category": "Pizza",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 334,
    "ingredients": [
      "Mozzarella",
      "Gorgonzola",
      "Parmesan",
      "Fontina"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=85"
  },
  {
    "id": "hawaiian",
    "name": "Hawaiian",
    "description": "Ham, pineapple, mozzarella, and sweet tomato base.",
    "price": 14,
    "rating": 4.4,
    "time": "20 min",
    "kcal": "720 Kcal",
    "category": "Pizza",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 389,
    "ingredients": [
      "Ham",
      "Pineapple",
      "Mozzarella",
      "Tomato"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=500&q=85"
  },
  {
    "id": "meat-lovers",
    "name": "Meat Lovers",
    "description": "Pepperoni, sausage, bacon, ham, and extra mozzarella.",
    "price": 16.5,
    "rating": 4.8,
    "time": "25 min",
    "kcal": "980 Kcal",
    "category": "Pizza",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 567,
    "ingredients": [
      "Pepperoni",
      "Sausage",
      "Bacon",
      "Ham"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500&q=85"
  },
  {
    "id": "buffalo-chicken-pizza",
    "name": "Buffalo Chicken",
    "description": "Spicy buffalo chicken, blue cheese, celery, mozzarella.",
    "price": 15.75,
    "rating": 4.6,
    "time": "22 min",
    "kcal": "840 Kcal",
    "category": "Pizza",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 241,
    "ingredients": [
      "Chicken",
      "Buffalo sauce",
      "Blue cheese",
      "Celery"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=500&q=85"
  },
  {
    "id": "prosciutto-arugula",
    "name": "Prosciutto Arugula",
    "description": "Thin prosciutto, fresh arugula, parmesan, balsamic glaze.",
    "price": 16,
    "rating": 4.7,
    "time": "22 min",
    "kcal": "680 Kcal",
    "category": "Pizza",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 198,
    "ingredients": [
      "Prosciutto",
      "Arugula",
      "Parmesan",
      "Balsamic"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?w=500&q=85"
  },
  {
    "id": "burger",
    "name": "Smash burger",
    "description": "Double smash patty, cheddar, pickles, special sauce.",
    "price": 12.5,
    "rating": 4.8,
    "time": "18 min",
    "kcal": "690 Kcal",
    "category": "Burger",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 901,
    "ingredients": [
      "Beef",
      "Cheddar",
      "Pickle",
      "Bun"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=85"
  },
  {
    "id": "classic-cheeseburger",
    "name": "Classic Cheeseburger",
    "description": "Angus beef, American cheese, lettuce, tomato, onion.",
    "price": 11.5,
    "rating": 4.6,
    "time": "16 min",
    "kcal": "620 Kcal",
    "category": "Burger",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 654,
    "ingredients": [
      "Beef",
      "Cheese",
      "Lettuce",
      "Tomato"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&q=85"
  },
  {
    "id": "bacon-bbq-burger",
    "name": "Bacon BBQ Burger",
    "description": "Crispy bacon, smoky BBQ glaze, onion rings, cheddar.",
    "price": 13.75,
    "rating": 4.9,
    "time": "20 min",
    "kcal": "880 Kcal",
    "category": "Burger",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 712,
    "ingredients": [
      "Beef",
      "Bacon",
      "BBQ sauce",
      "Onion rings"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=500&q=85"
  },
  {
    "id": "mushroom-swiss",
    "name": "Mushroom Swiss",
    "description": "Sautéed mushrooms, Swiss cheese, garlic aioli on brioche.",
    "price": 12.75,
    "rating": 4.7,
    "time": "18 min",
    "kcal": "710 Kcal",
    "category": "Burger",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 321,
    "ingredients": [
      "Beef",
      "Mushroom",
      "Swiss",
      "Aioli"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=500&q=85"
  },
  {
    "id": "veggie-burger",
    "name": "Plant-Based Burger",
    "description": "Beyond patty, avocado, sprouts, chipotle mayo.",
    "price": 12,
    "rating": 4.5,
    "time": "16 min",
    "kcal": "540 Kcal",
    "category": "Burger",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 287,
    "ingredients": [
      "Plant patty",
      "Avocado",
      "Sprouts",
      "Chipotle mayo"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1520072959219-c595dc870360?w=500&q=85"
  },
  {
    "id": "spicy-jalapeno-burger",
    "name": "Spicy Jalapeño",
    "description": "Pepper jack, jalapeños, sriracha mayo, crispy onions.",
    "price": 13,
    "rating": 4.6,
    "time": "18 min",
    "kcal": "740 Kcal",
    "category": "Burger",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 445,
    "ingredients": [
      "Beef",
      "Jalapeño",
      "Pepper jack",
      "Sriracha"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=500&q=85"
  },
  {
    "id": "chicken-burger",
    "name": "Crispy Chicken Burger",
    "description": "Buttermilk fried chicken, coleslaw, pickles, honey mustard.",
    "price": 11.75,
    "rating": 4.7,
    "time": "17 min",
    "kcal": "650 Kcal",
    "category": "Burger",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 508,
    "ingredients": [
      "Chicken",
      "Coleslaw",
      "Pickle",
      "Honey mustard"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=500&q=85"
  },
  {
    "id": "kebab",
    "name": "Kebab wrap",
    "description": "Grilled kebab, fresh salad, garlic sauce in warm flatbread.",
    "price": 11,
    "rating": 4.7,
    "time": "15 min",
    "kcal": "520 Kcal",
    "category": "Wraps",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 512,
    "ingredients": [
      "Kebab",
      "Lettuce",
      "Tomato",
      "Garlic sauce"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500&q=85"
  },
  {
    "id": "chicken-caesar-wrap",
    "name": "Chicken Caesar Wrap",
    "description": "Grilled chicken, romaine, parmesan, Caesar dressing.",
    "price": 10.5,
    "rating": 4.5,
    "time": "12 min",
    "kcal": "480 Kcal",
    "category": "Wraps",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 356,
    "ingredients": [
      "Chicken",
      "Romaine",
      "Parmesan",
      "Caesar"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500&q=85"
  },
  {
    "id": "falafel-wrap",
    "name": "Falafel Wrap",
    "description": "Crispy falafel, hummus, pickled veg, tahini in pita.",
    "price": 9.5,
    "rating": 4.6,
    "time": "14 min",
    "kcal": "450 Kcal",
    "category": "Wraps",
    "isPopular": true,
    "isVeg": true,
    "reviewCount": 423,
    "ingredients": [
      "Falafel",
      "Hummus",
      "Pickles",
      "Tahini"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500&q=85"
  },
  {
    "id": "shawarma-wrap",
    "name": "Chicken Shawarma",
    "description": "Marinated shawarma, garlic sauce, fries, pickles.",
    "price": 11.5,
    "rating": 4.8,
    "time": "15 min",
    "kcal": "580 Kcal",
    "category": "Wraps",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 689,
    "ingredients": [
      "Chicken",
      "Garlic sauce",
      "Fries",
      "Pickles"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1561651823-34feb02250e4?w=500&q=85"
  },
  {
    "id": "buffalo-wrap",
    "name": "Buffalo Chicken Wrap",
    "description": "Crispy buffalo chicken, ranch, lettuce, blue cheese.",
    "price": 10.75,
    "rating": 4.5,
    "time": "14 min",
    "kcal": "540 Kcal",
    "category": "Wraps",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 278,
    "ingredients": [
      "Chicken",
      "Buffalo sauce",
      "Ranch",
      "Blue cheese"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500&q=85"
  },
  {
    "id": "sushi",
    "name": "Salmon roll",
    "description": "Fresh salmon, avocado, cucumber, sushi rice.",
    "price": 16,
    "rating": 4.6,
    "time": "25 min",
    "kcal": "380 Kcal",
    "category": "Asian",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 267,
    "ingredients": [
      "Salmon",
      "Avocado",
      "Rice",
      "Nori"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=85"
  },
  {
    "id": "ramen",
    "name": "Tonkotsu Ramen",
    "description": "Rich pork broth, chashu, soft egg, nori, green onion.",
    "price": 14.5,
    "rating": 4.9,
    "time": "22 min",
    "kcal": "620 Kcal",
    "category": "Asian",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 734,
    "ingredients": [
      "Pork broth",
      "Chashu",
      "Egg",
      "Noodles"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&q=85"
  },
  {
    "id": "pad-thai",
    "name": "Pad Thai",
    "description": "Rice noodles, tamarind sauce, shrimp, peanuts, lime.",
    "price": 13.5,
    "rating": 4.7,
    "time": "20 min",
    "kcal": "580 Kcal",
    "category": "Asian",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 492,
    "ingredients": [
      "Rice noodles",
      "Shrimp",
      "Peanut",
      "Tamarind"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1559314809-0d155014e29e?w=500&q=85"
  },
  {
    "id": "chicken-teriyaki",
    "name": "Chicken Teriyaki Bowl",
    "description": "Grilled teriyaki chicken, steamed rice, broccoli, sesame.",
    "price": 12.5,
    "rating": 4.6,
    "time": "18 min",
    "kcal": "540 Kcal",
    "category": "Asian",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 381,
    "ingredients": [
      "Chicken",
      "Teriyaki",
      "Rice",
      "Broccoli"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=85"
  },
  {
    "id": "dumplings",
    "name": "Pork Dumplings",
    "description": "Steamed pork dumplings with ginger soy dipping sauce.",
    "price": 9.5,
    "rating": 4.5,
    "time": "15 min",
    "kcal": "320 Kcal",
    "category": "Asian",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 256,
    "ingredients": [
      "Pork",
      "Ginger",
      "Soy",
      "Wrapper"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=500&q=85"
  },
  {
    "id": "pho",
    "name": "Beef Pho",
    "description": "Fragrant beef broth, rice noodles, herbs, lime.",
    "price": 13,
    "rating": 4.8,
    "time": "20 min",
    "kcal": "450 Kcal",
    "category": "Asian",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 418,
    "ingredients": [
      "Beef",
      "Rice noodles",
      "Herbs",
      "Broth"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=500&q=85"
  },
  {
    "id": "california-roll",
    "name": "California Roll",
    "description": "Crab, avocado, cucumber, sesame outside.",
    "price": 12,
    "rating": 4.4,
    "time": "20 min",
    "kcal": "340 Kcal",
    "category": "Asian",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 189,
    "ingredients": [
      "Crab",
      "Avocado",
      "Cucumber",
      "Sesame"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=500&q=85"
  },
  {
    "id": "spicy-tuna-roll",
    "name": "Spicy Tuna Roll",
    "description": "Spicy tuna, cucumber, sriracha mayo, tobiko.",
    "price": 14,
    "rating": 4.7,
    "time": "22 min",
    "kcal": "360 Kcal",
    "category": "Asian",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 312,
    "ingredients": [
      "Tuna",
      "Sriracha",
      "Cucumber",
      "Tobiko"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=500&q=85"
  },
  {
    "id": "fried-rice",
    "name": "Chicken Fried Rice",
    "description": "Wok-fried rice, chicken, egg, peas, carrots, soy.",
    "price": 11,
    "rating": 4.5,
    "time": "16 min",
    "kcal": "520 Kcal",
    "category": "Asian",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 445,
    "ingredients": [
      "Rice",
      "Chicken",
      "Egg",
      "Peas"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500&q=85"
  },
  {
    "id": "bowl",
    "name": "Green bowl",
    "description": "Quinoa, roasted veggies, avocado, tahini drizzle.",
    "price": 13,
    "rating": 4.5,
    "time": "12 min",
    "kcal": "420 Kcal",
    "category": "Healthy",
    "isPopular": true,
    "isVeg": true,
    "reviewCount": 178,
    "ingredients": [
      "Quinoa",
      "Avocado",
      "Veggies",
      "Tahini"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=85"
  },
  {
    "id": "caesar-salad",
    "name": "Chicken Caesar Salad",
    "description": "Romaine, grilled chicken, croutons, parmesan, Caesar.",
    "price": 11.5,
    "rating": 4.4,
    "time": "12 min",
    "kcal": "390 Kcal",
    "category": "Healthy",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 298,
    "ingredients": [
      "Romaine",
      "Chicken",
      "Croutons",
      "Parmesan"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1546793665-c74683f339c1?w=500&q=85"
  },
  {
    "id": "poke-bowl",
    "name": "Ahi Poke Bowl",
    "description": "Raw ahi tuna, rice, edamame, mango, sesame dressing.",
    "price": 15.5,
    "rating": 4.8,
    "time": "15 min",
    "kcal": "480 Kcal",
    "category": "Healthy",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 367,
    "ingredients": [
      "Tuna",
      "Rice",
      "Edamame",
      "Mango"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=85"
  },
  {
    "id": "greek-salad",
    "name": "Greek Salad",
    "description": "Cucumber, tomato, feta, olives, red onion, oregano.",
    "price": 10,
    "rating": 4.5,
    "time": "10 min",
    "kcal": "320 Kcal",
    "category": "Healthy",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 214,
    "ingredients": [
      "Cucumber",
      "Tomato",
      "Feta",
      "Olives"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=500&q=85"
  },
  {
    "id": "acai-bowl",
    "name": "Acai Berry Bowl",
    "description": "Acai blend, granola, banana, berries, honey drizzle.",
    "price": 11,
    "rating": 4.7,
    "time": "10 min",
    "kcal": "380 Kcal",
    "category": "Healthy",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 289,
    "ingredients": [
      "Acai",
      "Granola",
      "Banana",
      "Berries"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500&q=85"
  },
  {
    "id": "salmon-salad",
    "name": "Grilled Salmon Salad",
    "description": "Salmon, mixed greens, cherry tomato, lemon vinaigrette.",
    "price": 15,
    "rating": 4.8,
    "time": "18 min",
    "kcal": "440 Kcal",
    "category": "Healthy",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 341,
    "ingredients": [
      "Salmon",
      "Greens",
      "Tomato",
      "Lemon"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500&q=85"
  },
  {
    "id": "buddha-bowl",
    "name": "Buddha Bowl",
    "description": "Brown rice, chickpeas, kale, sweet potato, tahini.",
    "price": 12.5,
    "rating": 4.6,
    "time": "14 min",
    "kcal": "460 Kcal",
    "category": "Healthy",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 256,
    "ingredients": [
      "Brown rice",
      "Chickpeas",
      "Kale",
      "Sweet potato"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1546069901-d5bfd2cbfb1f?w=500&q=85"
  },
  {
    "id": "spaghetti-bolognese",
    "name": "Spaghetti Bolognese",
    "description": "Slow-cooked beef ragu, parmesan, fresh basil.",
    "price": 13.5,
    "rating": 4.7,
    "time": "20 min",
    "kcal": "680 Kcal",
    "category": "Pasta",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 523,
    "ingredients": [
      "Spaghetti",
      "Beef ragu",
      "Parmesan",
      "Basil"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1622973536968-3ead9e780960?w=500&q=85"
  },
  {
    "id": "fettuccine-alfredo",
    "name": "Fettuccine Alfredo",
    "description": "Creamy parmesan sauce, fettuccine, cracked pepper.",
    "price": 12.5,
    "rating": 4.6,
    "time": "18 min",
    "kcal": "720 Kcal",
    "category": "Pasta",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 412,
    "ingredients": [
      "Fettuccine",
      "Cream",
      "Parmesan",
      "Butter"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1645112411341-6c4fd023714a?w=500&q=85"
  },
  {
    "id": "penne-arrabiata",
    "name": "Penne Arrabbiata",
    "description": "Spicy tomato sauce, garlic, chili flakes, parsley.",
    "price": 11.5,
    "rating": 4.5,
    "time": "16 min",
    "kcal": "520 Kcal",
    "category": "Pasta",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 267,
    "ingredients": [
      "Penne",
      "Tomato",
      "Chili",
      "Garlic"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=500&q=85"
  },
  {
    "id": "pesto-pasta",
    "name": "Basil Pesto Pasta",
    "description": "House basil pesto, cherry tomatoes, pine nuts, parmesan.",
    "price": 12,
    "rating": 4.6,
    "time": "16 min",
    "kcal": "580 Kcal",
    "category": "Pasta",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 334,
    "ingredients": [
      "Pasta",
      "Basil pesto",
      "Tomato",
      "Pine nuts"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=500&q=85"
  },
  {
    "id": "lasagna",
    "name": "Beef Lasagna",
    "description": "Layered pasta, beef ragu, bechamel, mozzarella.",
    "price": 14.5,
    "rating": 4.8,
    "time": "25 min",
    "kcal": "780 Kcal",
    "category": "Pasta",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 598,
    "ingredients": [
      "Pasta sheets",
      "Beef",
      "Bechamel",
      "Mozzarella"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=500&q=85"
  },
  {
    "id": "shrimp-scampi",
    "name": "Shrimp Scampi",
    "description": "Garlic butter shrimp, linguine, white wine, parsley.",
    "price": 16,
    "rating": 4.7,
    "time": "20 min",
    "kcal": "610 Kcal",
    "category": "Pasta",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 289,
    "ingredients": [
      "Shrimp",
      "Linguine",
      "Garlic",
      "Butter"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=500&q=85"
  },
  {
    "id": "pancakes",
    "name": "Fluffy Pancakes",
    "description": "Stack of three, maple syrup, butter, fresh berries.",
    "price": 9.5,
    "rating": 4.7,
    "time": "15 min",
    "kcal": "520 Kcal",
    "category": "Breakfast",
    "isPopular": true,
    "isVeg": true,
    "reviewCount": 445,
    "ingredients": [
      "Flour",
      "Egg",
      "Maple syrup",
      "Berries"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500&q=85"
  },
  {
    "id": "avocado-toast",
    "name": "Avocado Toast",
    "description": "Sourdough, smashed avocado, chili flakes, poached egg.",
    "price": 9,
    "rating": 4.5,
    "time": "12 min",
    "kcal": "380 Kcal",
    "category": "Breakfast",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 312,
    "ingredients": [
      "Sourdough",
      "Avocado",
      "Egg",
      "Chili"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=500&q=85"
  },
  {
    "id": "eggs-benedict",
    "name": "Eggs Benedict",
    "description": "Poached eggs, Canadian bacon, hollandaise on English muffin.",
    "price": 12.5,
    "rating": 4.8,
    "time": "18 min",
    "kcal": "560 Kcal",
    "category": "Breakfast",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 378,
    "ingredients": [
      "Egg",
      "Bacon",
      "Hollandaise",
      "Muffin"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=500&q=85"
  },
  {
    "id": "breakfast-burrito",
    "name": "Breakfast Burrito",
    "description": "Eggs, sausage, cheese, salsa, hash browns wrapped up.",
    "price": 10.5,
    "rating": 4.6,
    "time": "14 min",
    "kcal": "640 Kcal",
    "category": "Breakfast",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 401,
    "ingredients": [
      "Egg",
      "Sausage",
      "Cheese",
      "Salsa"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500&q=85"
  },
  {
    "id": "french-toast",
    "name": "French Toast",
    "description": "Brioche French toast, powdered sugar, berry compote.",
    "price": 10,
    "rating": 4.6,
    "time": "15 min",
    "kcal": "480 Kcal",
    "category": "Breakfast",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 267,
    "ingredients": [
      "Brioche",
      "Egg",
      "Sugar",
      "Berries"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=500&q=85"
  },
  {
    "id": "omelette",
    "name": "Garden Omelette",
    "description": "Three-egg omelette with spinach, mushroom, cheddar.",
    "price": 9.75,
    "rating": 4.4,
    "time": "14 min",
    "kcal": "420 Kcal",
    "category": "Breakfast",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 198,
    "ingredients": [
      "Egg",
      "Spinach",
      "Mushroom",
      "Cheddar"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1510693206972-df098062cb71?w=500&q=85"
  },
  {
    "id": "dessert",
    "name": "Lava cake",
    "description": "Warm chocolate cake with molten center and ice cream.",
    "price": 8.5,
    "rating": 4.9,
    "time": "15 min",
    "kcal": "450 Kcal",
    "category": "Dessert",
    "isPopular": true,
    "isVeg": true,
    "reviewCount": 456,
    "ingredients": [
      "Chocolate",
      "Butter",
      "Egg",
      "Ice cream"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=500&q=85"
  },
  {
    "id": "cheesecake",
    "name": "NY Cheesecake",
    "description": "Creamy New York style with berry coulis.",
    "price": 7.5,
    "rating": 4.8,
    "time": "10 min",
    "kcal": "420 Kcal",
    "category": "Dessert",
    "isPopular": true,
    "isVeg": true,
    "reviewCount": 612,
    "ingredients": [
      "Cream cheese",
      "Graham",
      "Berry",
      "Sugar"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=500&q=85"
  },
  {
    "id": "tiramisu",
    "name": "Tiramisu",
    "description": "Espresso-soaked ladyfingers, mascarpone, cocoa.",
    "price": 8,
    "rating": 4.7,
    "time": "10 min",
    "kcal": "380 Kcal",
    "category": "Dessert",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 389,
    "ingredients": [
      "Mascarpone",
      "Espresso",
      "Cocoa",
      "Ladyfingers"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=500&q=85"
  },
  {
    "id": "brownie",
    "name": "Fudge Brownie",
    "description": "Double chocolate brownie, walnuts, vanilla ice cream.",
    "price": 6.5,
    "rating": 4.6,
    "time": "12 min",
    "kcal": "480 Kcal",
    "category": "Dessert",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 534,
    "ingredients": [
      "Chocolate",
      "Walnut",
      "Butter",
      "Ice cream"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&q=85"
  },
  {
    "id": "apple-pie",
    "name": "Apple Pie Slice",
    "description": "Warm cinnamon apple pie with vanilla ice cream.",
    "price": 7,
    "rating": 4.5,
    "time": "12 min",
    "kcal": "410 Kcal",
    "category": "Dessert",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 278,
    "ingredients": [
      "Apple",
      "Cinnamon",
      "Pastry",
      "Ice cream"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1535920527002-b35e96722eb9?w=500&q=85"
  },
  {
    "id": "churros",
    "name": "Churros",
    "description": "Crispy churros, cinnamon sugar, chocolate dipping sauce.",
    "price": 6,
    "rating": 4.7,
    "time": "12 min",
    "kcal": "360 Kcal",
    "category": "Dessert",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 445,
    "ingredients": [
      "Dough",
      "Cinnamon",
      "Sugar",
      "Chocolate"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1624371414361-e670edf4898d?w=500&q=85"
  },
  {
    "id": "creme-brulee",
    "name": "Crème Brûlée",
    "description": "Vanilla custard with caramelized sugar crust.",
    "price": 8.5,
    "rating": 4.8,
    "time": "10 min",
    "kcal": "340 Kcal",
    "category": "Dessert",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 312,
    "ingredients": [
      "Cream",
      "Vanilla",
      "Egg",
      "Sugar"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1470124182917-cc6e71b22ecc?w=500&q=85"
  },
  {
    "id": "icecream",
    "name": "Berry gelato",
    "description": "House berry gelato, three scoops.",
    "price": 6.5,
    "rating": 4.7,
    "time": "10 min",
    "kcal": "280 Kcal",
    "category": "Ice cream",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 133,
    "ingredients": [
      "Berry",
      "Cream",
      "Sugar"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500&q=85"
  },
  {
    "id": "chocolate-sundae",
    "name": "Chocolate Sundae",
    "description": "Vanilla ice cream, hot fudge, whipped cream, cherry.",
    "price": 7.5,
    "rating": 4.8,
    "time": "10 min",
    "kcal": "420 Kcal",
    "category": "Ice cream",
    "isPopular": true,
    "isVeg": true,
    "reviewCount": 567,
    "ingredients": [
      "Vanilla",
      "Fudge",
      "Cream",
      "Cherry"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500&q=85"
  },
  {
    "id": "mango-sorbet",
    "name": "Mango Sorbet",
    "description": "Refreshing dairy-free mango sorbet, two scoops.",
    "price": 5.5,
    "rating": 4.5,
    "time": "8 min",
    "kcal": "180 Kcal",
    "category": "Ice cream",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 198,
    "ingredients": [
      "Mango",
      "Sugar",
      "Lemon"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1488900128323-21503983a07e?w=500&q=85"
  },
  {
    "id": "cookie-dough",
    "name": "Cookie Dough Scoop",
    "description": "Vanilla ice cream loaded with cookie dough chunks.",
    "price": 6,
    "rating": 4.6,
    "time": "8 min",
    "kcal": "340 Kcal",
    "category": "Ice cream",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 423,
    "ingredients": [
      "Vanilla",
      "Cookie dough",
      "Chocolate chips"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=500&q=85"
  },
  {
    "id": "affogato",
    "name": "Affogato",
    "description": "Vanilla gelato drowned in a shot of hot espresso.",
    "price": 6.5,
    "rating": 4.7,
    "time": "8 min",
    "kcal": "220 Kcal",
    "category": "Ice cream",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 256,
    "ingredients": [
      "Gelato",
      "Espresso"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500&q=85"
  },
  {
    "id": "banana-split",
    "name": "Banana Split",
    "description": "Banana, three scoops, sauces, nuts, whipped cream.",
    "price": 8.5,
    "rating": 4.6,
    "time": "12 min",
    "kcal": "520 Kcal",
    "category": "Ice cream",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 334,
    "ingredients": [
      "Banana",
      "Ice cream",
      "Sauces",
      "Nuts"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1579954115545-a95591f28bfc?w=500&q=85"
  },
  {
    "id": "coffee",
    "name": "Cappuccino",
    "description": "Double espresso with steamed milk foam.",
    "price": 4.5,
    "rating": 4.4,
    "time": "8 min",
    "kcal": "90 Kcal",
    "category": "Coffee",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 210,
    "ingredients": [
      "Espresso",
      "Milk",
      "Foam"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=500&q=85"
  },
  {
    "id": "latte",
    "name": "Caffe Latte",
    "description": "Smooth espresso with steamed milk, light foam.",
    "price": 4.75,
    "rating": 4.5,
    "time": "8 min",
    "kcal": "120 Kcal",
    "category": "Coffee",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 389,
    "ingredients": [
      "Espresso",
      "Milk"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1561882468-9110e03e0f78?w=500&q=85"
  },
  {
    "id": "americano",
    "name": "Americano",
    "description": "Double espresso diluted with hot water.",
    "price": 3.5,
    "rating": 4.3,
    "time": "6 min",
    "kcal": "10 Kcal",
    "category": "Coffee",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 178,
    "ingredients": [
      "Espresso",
      "Water"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&q=85"
  },
  {
    "id": "mocha",
    "name": "Mocha",
    "description": "Espresso, chocolate, steamed milk, whipped cream.",
    "price": 5.25,
    "rating": 4.6,
    "time": "8 min",
    "kcal": "250 Kcal",
    "category": "Coffee",
    "isPopular": true,
    "isVeg": true,
    "reviewCount": 445,
    "ingredients": [
      "Espresso",
      "Chocolate",
      "Milk",
      "Cream"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?w=500&q=85"
  },
  {
    "id": "cold-brew",
    "name": "Cold Brew",
    "description": "Slow-steeped cold brew over ice, bold and smooth.",
    "price": 4.75,
    "rating": 4.5,
    "time": "5 min",
    "kcal": "15 Kcal",
    "category": "Coffee",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 312,
    "ingredients": [
      "Coffee",
      "Ice"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=500&q=85"
  },
  {
    "id": "matcha-latte",
    "name": "Matcha Latte",
    "description": "Ceremonial matcha whisked with steamed milk.",
    "price": 5.5,
    "rating": 4.6,
    "time": "8 min",
    "kcal": "140 Kcal",
    "category": "Coffee",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 267,
    "ingredients": [
      "Matcha",
      "Milk"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500&q=85"
  },
  {
    "id": "caramel-macchiato",
    "name": "Caramel Macchiato",
    "description": "Vanilla milk, espresso shot, caramel drizzle.",
    "price": 5.5,
    "rating": 4.7,
    "time": "8 min",
    "kcal": "250 Kcal",
    "category": "Coffee",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 498,
    "ingredients": [
      "Espresso",
      "Vanilla",
      "Milk",
      "Caramel"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=500&q=85"
  },
  {
    "id": "espresso",
    "name": "Espresso",
    "description": "Single or double shot of our house espresso blend.",
    "price": 3,
    "rating": 4.4,
    "time": "5 min",
    "kcal": "5 Kcal",
    "category": "Coffee",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 156,
    "ingredients": [
      "Espresso"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=500&q=85"
  },
  {
    "id": "wings",
    "name": "Buffalo Wings",
    "description": "Crispy wings tossed in buffalo sauce, ranch dip.",
    "price": 11,
    "rating": 4.7,
    "time": "20 min",
    "kcal": "640 Kcal",
    "category": "Burger",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 678,
    "ingredients": [
      "Chicken wings",
      "Buffalo sauce",
      "Ranch"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1608039755401-742074f0548d?w=500&q=85"
  },
  {
    "id": "fries",
    "name": "Truffle Fries",
    "description": "Crispy fries, truffle oil, parmesan, herbs.",
    "price": 6.5,
    "rating": 4.6,
    "time": "12 min",
    "kcal": "420 Kcal",
    "category": "Burger",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 534,
    "ingredients": [
      "Potato",
      "Truffle oil",
      "Parmesan",
      "Herbs"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500&q=85"
  },
  {
    "id": "nachos",
    "name": "Loaded Nachos",
    "description": "Tortilla chips, cheese, jalapeño, salsa, sour cream, guac.",
    "price": 10.5,
    "rating": 4.5,
    "time": "14 min",
    "kcal": "720 Kcal",
    "category": "Wraps",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 389,
    "ingredients": [
      "Chips",
      "Cheese",
      "Jalapeño",
      "Guacamole"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?w=500&q=85"
  },
  {
    "id": "tacos",
    "name": "Street Tacos",
    "description": "Three corn tacos with carne asada, onion, cilantro.",
    "price": 11.5,
    "rating": 4.8,
    "time": "15 min",
    "kcal": "480 Kcal",
    "category": "Wraps",
    "isPopular": true,
    "isVeg": false,
    "reviewCount": 712,
    "ingredients": [
      "Beef",
      "Corn tortilla",
      "Onion",
      "Cilantro"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=500&q=85"
  },
  {
    "id": "fish-tacos",
    "name": "Fish Tacos",
    "description": "Beer-battered fish, cabbage slaw, chipotle crema.",
    "price": 12.5,
    "rating": 4.6,
    "time": "16 min",
    "kcal": "450 Kcal",
    "category": "Wraps",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 345,
    "ingredients": [
      "Fish",
      "Slaw",
      "Chipotle crema",
      "Tortilla"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=500&q=85"
  },
  {
    "id": "club-sandwich",
    "name": "Club Sandwich",
    "description": "Turkey, bacon, lettuce, tomato, mayo on toasted bread.",
    "price": 11,
    "rating": 4.5,
    "time": "14 min",
    "kcal": "580 Kcal",
    "category": "Breakfast",
    "isPopular": false,
    "isVeg": false,
    "reviewCount": 267,
    "ingredients": [
      "Turkey",
      "Bacon",
      "Lettuce",
      "Tomato"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=500&q=85"
  },
  {
    "id": "grilled-cheese",
    "name": "Grilled Cheese",
    "description": "Three-cheese melt on sourdough, tomato soup side.",
    "price": 8.5,
    "rating": 4.4,
    "time": "12 min",
    "kcal": "520 Kcal",
    "category": "Breakfast",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 289,
    "ingredients": [
      "Cheese",
      "Sourdough",
      "Butter",
      "Tomato soup"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1528736235302-52922df5c122?w=500&q=85"
  },
  {
    "id": "mac-and-cheese",
    "name": "Mac & Cheese",
    "description": "Creamy three-cheese mac, breadcrumbs, chives.",
    "price": 9.5,
    "rating": 4.6,
    "time": "15 min",
    "kcal": "620 Kcal",
    "category": "Pasta",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 478,
    "ingredients": [
      "Macaroni",
      "Cheddar",
      "Cream",
      "Breadcrumbs"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1543339494-b4cd4f7ba686?w=500&q=85"
  },
  {
    "id": "onion-rings",
    "name": "Onion Rings",
    "description": "Beer-battered onion rings with spicy ketchup.",
    "price": 5.5,
    "rating": 4.4,
    "time": "12 min",
    "kcal": "380 Kcal",
    "category": "Burger",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 234,
    "ingredients": [
      "Onion",
      "Batter",
      "Ketchup"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1639024471283-03518883512d?w=500&q=85"
  },
  {
    "id": "smoothie",
    "name": "Berry Protein Smoothie",
    "description": "Mixed berries, banana, protein, almond milk.",
    "price": 7.5,
    "rating": 4.5,
    "time": "8 min",
    "kcal": "280 Kcal",
    "category": "Healthy",
    "isPopular": false,
    "isVeg": true,
    "reviewCount": 312,
    "ingredients": [
      "Berries",
      "Banana",
      "Protein",
      "Almond milk"
    ],
    "imageUrl": "https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=500&q=85"
  }
];

const CATEGORIES = [
  {
    "id": "dessert",
    "name": "Dessert",
    "emoji": "🍰"
  },
  {
    "id": "ice_cream",
    "name": "Ice cream",
    "emoji": "🍦"
  },
  {
    "id": "pizza",
    "name": "Pizza",
    "emoji": "🍕"
  },
  {
    "id": "coffee",
    "name": "Coffee",
    "emoji": "☕"
  },
  {
    "id": "burger",
    "name": "Burger",
    "emoji": "🍔"
  },
  {
    "id": "asian",
    "name": "Asian",
    "emoji": "🍜"
  },
  {
    "id": "healthy",
    "name": "Healthy",
    "emoji": "🥗"
  },
  {
    "id": "wraps",
    "name": "Wraps",
    "emoji": "🌯"
  },
  {
    "id": "pasta",
    "name": "Pasta",
    "emoji": "🍝"
  },
  {
    "id": "breakfast",
    "name": "Breakfast",
    "emoji": "🥞"
  }
];

function loadFirebaseTokens() {
  const p = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
  if (!fs.existsSync(p)) {
    throw new Error(`Firebase CLI config not found at ${p}. Run: firebase login`);
  }
  const conf = JSON.parse(fs.readFileSync(p, 'utf8'));
  if (!conf.tokens?.refresh_token) {
    throw new Error('No refresh_token in firebase-tools.json. Run: firebase login');
  }
  return conf.tokens;
}

function httpsRequest(url, options, body) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const req = https.request(
      {
        hostname: u.hostname,
        path: u.pathname + u.search,
        method: options.method || 'GET',
        headers: options.headers || {},
      },
      (res) => {
        let data = '';
        res.on('data', (c) => (data += c));
        res.on('end', () => {
          let json = null;
          try {
            json = data ? JSON.parse(data) : null;
          } catch {
            json = { raw: data };
          }
          resolve({ status: res.statusCode, json, raw: data });
        });
      },
    );
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function getAccessToken(tokens) {
  // Reuse cached CLI access token when still valid
  if (tokens.access_token && tokens.expires_at && tokens.expires_at > Date.now() + 60_000) {
    return tokens.access_token;
  }

  // Firebase CLI public OAuth client (from firebase-tools)
  // Load from installed package if present
  let clientId =
    '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
  let clientSecret = 'jEQSVOTREDySouVX5sqtdah2';
  try {
    const api = await import(
      'file:///C:/nvm4w/nodejs/node_modules/firebase-tools/lib/api.js'
    );
    if (api.clientId) clientId = api.clientId();
    if (api.clientSecret) clientSecret = api.clientSecret();
  } catch {
    // use defaults
  }

  const body = new URLSearchParams({
    client_id: clientId,
    client_secret: clientSecret,
    refresh_token: tokens.refresh_token,
    grant_type: 'refresh_token',
  }).toString();

  const res = await httpsRequest('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': Buffer.byteLength(body),
    },
  }, body);

  if (res.status !== 200 || !res.json?.access_token) {
    throw new Error(`Token refresh failed: ${res.status} ${res.raw}`);
  }
  return res.json.access_token;
}

function toFirestoreFields(obj) {
  const fields = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v === null || v === undefined) continue;
    if (typeof v === 'string') fields[k] = { stringValue: v };
    else if (typeof v === 'boolean') fields[k] = { booleanValue: v };
    else if (typeof v === 'number') {
      fields[k] = Number.isInteger(v)
        ? { integerValue: String(v) }
        : { doubleValue: v };
    } else if (Array.isArray(v)) {
      fields[k] = {
        arrayValue: {
          values: v.map((item) =>
            typeof item === 'string'
              ? { stringValue: item }
              : typeof item === 'number'
                ? { doubleValue: item }
                : { stringValue: String(item) },
          ),
        },
      };
    }
  }
  return fields;
}

async function patchDocument(accessToken, databaseId, collection, docId, data) {
  const dbEnc = encodeURIComponent(databaseId);
  const url =
    `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/${dbEnc}/documents/${collection}/${docId}`;
  const body = JSON.stringify({ fields: toFirestoreFields(data) });
  const res = await httpsRequest(
    url,
    {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    },
    body,
  );
  return res;
}

async function listDatabases(accessToken) {
  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases`;
  return httpsRequest(url, {
    method: 'GET',
    headers: { Authorization: `Bearer ${accessToken}` },
  });
}

async function createDatabase(accessToken, databaseId, locationId = 'nam5') {
  const url =
    `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases?databaseId=${encodeURIComponent(databaseId)}`;
  const body = JSON.stringify({
    type: 'FIRESTORE_NATIVE',
    locationId,
  });
  return httpsRequest(
    url,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    },
    body,
  );
}

async function enableEmailPasswordAuth(accessToken) {
  // Identity Toolkit admin API
  const url = `https://identitytoolkit.googleapis.com/admin/v2/projects/${PROJECT_ID}/config?updateMask=signIn.email`;
  const body = JSON.stringify({
    signIn: {
      email: {
        enabled: true,
        passwordRequired: true,
      },
    },
  });
  return httpsRequest(
    url,
    {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    },
    body,
  );
}

async function main() {
  console.log('=== FoodieGo Firebase full setup ===');
  console.log('Project:', PROJECT_ID);

  const tokens = loadFirebaseTokens();
  console.log('Getting access token…');
  const accessToken = await getAccessToken(tokens);
  console.log('Token OK');

  // Auth
  console.log('Enabling Email/Password auth…');
  const authRes = await enableEmailPasswordAuth(accessToken);
  console.log('Auth config status:', authRes.status, authRes.json?.error?.message || 'ok');

  // Databases
  console.log('Listing databases…');
  const listRes = await listDatabases(accessToken);
  console.log('List status:', listRes.status);
  const dbs = listRes.json?.databases || [];
  const names = dbs.map((d) => d.name?.split('/').pop());
  console.log('Existing DBs:', names.join(', ') || '(none)');

  // Named secondary DBs require billing; seed the free (default) database.
  const seedTargets = names.includes(DEFAULT_DB)
    ? [DEFAULT_DB]
    : names.length
      ? [names[0]]
      : [DEFAULT_DB];

  console.log('Seed targets:', seedTargets.join(', '));

  for (const dbId of seedTargets) {
    console.log(`\n--- Seeding database: ${dbId} ---`);
    let ok = 0;
    let fail = 0;

    for (const food of FOODS) {
      const { id, ...data } = food;
      const res = await patchDocument(accessToken, dbId, 'foods', id, data);
      if (res.status >= 200 && res.status < 300) {
        ok++;
        process.stdout.write(`  ✓ foods/${id}\n`);
      } else {
        fail++;
        process.stdout.write(
          `  ✗ foods/${id} → ${res.status} ${res.json?.error?.message || res.raw}\n`,
        );
      }
    }

    for (const cat of CATEGORIES) {
      const { id, ...data } = cat;
      const res = await patchDocument(accessToken, dbId, 'categories', id, data);
      if (res.status >= 200 && res.status < 300) {
        ok++;
        process.stdout.write(`  ✓ categories/${id}\n`);
      } else {
        fail++;
        process.stdout.write(
          `  ✗ categories/${id} → ${res.status} ${res.json?.error?.message || ''}\n`,
        );
      }
    }

    await patchDocument(accessToken, dbId, '_meta', 'seed', {
      app: 'FoodieGo',
      seededAt: new Date().toISOString(),
      foodCount: FOODS.length,
    });

    console.log(`Seeded ${ok} docs, ${fail} failed on ${dbId}`);
  }

  console.log('\n=== Done ===');
  console.log('Open: https://console.firebase.google.com/project/foodiego-f2abf/firestore');
  console.log('Then run: flutter run');
}

main().catch((e) => {
  console.error('FATAL:', e);
  process.exit(1);
});
