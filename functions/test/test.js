// Chai is a commonly used library for creating unit test suites. It is easily extended with plugins.
const chai = require('chai');
const assert = chai.assert;
const Supertest = require('supertest');
const supertest = Supertest(process.env.BASE_URL);
const childProcess = require('child_process');

describe('Cloud Functions', () => {
    let val1, val2;
   // let myFunctions;
  
    before(() => {
      // If you want to run something before your tests
    });
  
    after(() => {
      // If you want to do cleanup tasks after your tests
    });

    it('Test 1: Print Hello World', async () => {
        await supertest
          .get('/hello-world')
          .expect(200)
          .expect(response => {
            assert.strictEqual(response.text, 'Hello World!');
          });
      });

    it('Test 2: Invalid URL', async () => {
        await supertest
          .get('/')
          .expect(404)
          .expect(response => {
            assert.strictEqual(response.status, 404);
          });  
    });

    it('Test 3: Increment once', async () => {
        await supertest
          .get('/api/read/:id')
          .expect(200)
          .expect(response => {
            val1 = response.body.count;
            });
    });

    it ('Test 4: Increment again and compare to prev value', async () => {
        await supertest
        .get('/api/read/:id')
        .expect(200)
        .expect(response => {
            val2 = response.body.count;
           console.log("before: ", val1, "after: ", val2);
           assert.notEqual(val1, val2, "expected");
        });  
    });

});