// let url = 'http://localhost:5001/challenge1-310911/us-central1/app/api/read/views';

let url = "https://gateway-8d6ygfs9.ew.gateway.dev/api/read/:id";
 
 const email = document.getElementById('text');
 const password = document.getElementById('password');

 // Your web app's Firebase configuration



 async function fetchCount(url){
    const response =  await fetch(url);
    var data =  await response.json();
    console.log(data.count); // Testing purposes: Inspect your console to see the data change
    let count = data.count;
    document.getElementById('counter').innerHTML = count;
 }
 
 fetchCount(url);
  // Initialize Firebase
  