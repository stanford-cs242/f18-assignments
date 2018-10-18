const assert = require("chai").assert;

const PAGE_SIZE = 65536;

module.exports = function getTests(runTest) {
  // A simple hash operation which writes the data to the zero address.
  // We don't want to use the allocator for Part 1 tests.
  const basicHash = (adler32, mem, str) => {
    let mem8 = new Uint8Array(mem.buffer);
    for (let i = 0; i < str.length; ++i) {
      mem8[i] = str.charCodeAt(i);
    }
    let hash = adler32(0, str.length);
    return hash;
  };

  const traverseHeap = mem => {
    let buffer = mem.buffer;
    let heap = [];
    let start = 0;
    while (start < buffer.byteLength) {
      let words = new Int32Array(buffer, start);
      let size = words[0];
      assert.isAtLeast(size, 0, "Malformed heap - invalid size.");

      let free = words[1];
      assert(free == 0 || free == 1, "free flag is either 0 or 1.");

      heap.push({ ptr: start + 8, size, free });
      start += 8 + size;
    }
    assert.equal(start, buffer.byteLength, "Malformed heap.");
    return heap;
  };

  // Takes in a string and expected hash result and returns two tests - one
  // on the stack-based AST and one on the recursive expression based AST.
  const basicHashTest = (string, result) =>
    runTest(`hash "${string}" (adler32)`, ({ adler32, mem }) => {
      assert.equal(
        basicHash(adler32, mem, string),
        result,
        "Hash result incorrect."
      );
    }).then(() =>
      runTest(`hash "${string}" (adler32v2)`, ({ adler32v2, mem }) => {
        assert.equal(
          basicHash(adler32v2, mem, string),
          result,
          "Hash result incorrect."
        );
      })
    );

  return [
    () => basicHashTest("", 1),
    () => basicHashTest("Hello World", 403375133),
    () => basicHashTest("Wikipedia", 300286872),
    () =>
      runTest("basic alloc()", ({ mem, alloc_init, alloc }) => {
        alloc_init();
        let ptr = alloc(1024);

        let words = new Int32Array(mem.buffer);
        assert.equal(ptr, 8, "The first block should be returned.");
        assert.equal(words[0], 1024, "Block size is incorrect.");
        assert.equal(words[1], 0, "Block free flag is incorrectly set.");

        assert.equal(words[2 + 1024 / 4], 64496);
        assert.equal(words[2 + 1024 / 4 + 1], 1);

        assert.equal(
          mem.buffer.byteLength,
          65536,
          "Memory should only be one page"
        );

        assert.deepEqual(
          traverseHeap(mem),
          [
            { ptr: 8, size: 1024, free: 0 },
            { ptr: 1040, size: 64496, free: 1 }
          ],
          "Unexpected Heap structure."
        );
      }),
    () =>
      runTest("basic free()", ({ mem, alloc_init, alloc, free }) => {
        alloc_init();
        let ptr = alloc(1024);
        free(ptr);

        let words = new Int32Array(mem.buffer);
        assert.equal(words[0], 1024, "Block size is incorrect.");
        assert.equal(words[1], 1, "Block free flag is incorrectly set.");

        assert.deepEqual(
          traverseHeap(mem),
          [
            { ptr: 8, size: 1024, free: 1 },
            { ptr: 1040, size: 64496, free: 1 }
          ],
          "Unexpected Heap structure."
        );
      }),
    () =>
      runTest(
        "heap segmentation",
        ({ mem, alloc_init, alloc, free }) => {
          alloc_init();
          let ptr = alloc(1024);
          assert.equal(ptr, 8, "The first block should be returned.");

          free(ptr);
          ptr = alloc(100);
          assert.equal(ptr, 8, "The first block should be returned.");

          assert.deepEqual(
            traverseHeap(mem),
            [
              { ptr: 8, size: 100, free: 0 },
              { ptr: 116, size: 916, free: 1 },
              { ptr: 1040, size: 64496, free: 1 }
            ],
            "Unexpected Heap structure."
          );
        }
      ),
    () =>
      runTest("alloc->free->alloc", ({ mem, alloc_init, alloc, free }) => {
        alloc_init();
        let ptr = alloc(1024);
        free(ptr);

        alloc(1024);

        assert.deepEqual(
          traverseHeap(mem),
          [
            { ptr: 8, size: 1024, free: 0 },
            { ptr: 1040, size: 64496, free: 1 }
          ],
          "Unexpected Heap structure."
        );
      }),
    () =>
      runTest("segmentation edge case", ({ mem, alloc_init, alloc, free }) => {
        alloc_init();
        let ptr = alloc(1024);
        free(ptr);

        alloc(1020);

        assert.deepEqual(
          traverseHeap(mem),
          [
            { ptr: 8, size: 1024, free: 0 },
            { ptr: 1040, size: 64496, free: 1 }
          ],
          "Unexpected Heap structure."
        );
      }),
    () =>
      runTest(
        "segmentation edge case 2",
        ({ mem, alloc_init, alloc, free }) => {
          alloc_init();
          let ptr = alloc(1024);
          free(ptr);

          alloc(1024 - 8);

          assert.deepEqual(
            traverseHeap(mem),
            [
              { ptr: 8, size: 1016, free: 0 },
              { ptr: 1032, size: 0, free: 1 },
              { ptr: 1040, size: 64496, free: 1 }
            ],
            "Unexpected Heap structure."
          );
        }
      ),
    () =>
      runTest("alloc too large", ({ mem, alloc_init, alloc, free }) => {
        alloc_init();
        try {
          alloc(PAGE_SIZE * 2);
          throw new Error("Alloc should have raised an error");
        } catch (e) {}
      }),
    () =>
      runTest("maximum alloc", ({ mem, alloc_init, alloc, free }) => {
        alloc_init();
        let ptr = alloc(PAGE_SIZE - 8);

        assert.deepEqual(
          traverseHeap(mem),
          [{ ptr: 8, size: 65528, free: 0 }],
          "Unexpected Heap structure."
        );
      }),
    () =>
      runTest("complex test", ({ mem, alloc_init, alloc, free }) => {
        alloc_init();
        let ptr1 = alloc(1024);
        let ptr2 = alloc(2048);
        let ptr3 = alloc(3072);

        free(ptr1);
        let ptr4 = alloc(512);
        let ptr5 = alloc(512);
        let ptr6 = alloc(512);

        assert.deepEqual(
          traverseHeap(mem),
          [
            { ptr: 8, size: 512, free: 0 },
            { ptr: 528, size: 504, free: 1 },
            { ptr: 1040, size: 2048, free: 0 },
            { ptr: 3096, size: 3072, free: 0 },
            { ptr: 6176, size: 512, free: 0 },
            { ptr: 6696, size: 512, free: 0 },
            { ptr: 7216, size: 58320, free: 1 }
          ],
          "Unexpected Heap structure."
        );
      }),
    () =>
      runTest(
        "hash + allocator test",
        ({ mem, alloc_init, alloc, free, adler32, adler32v2 }) => {
          alloc_init();

          let mem8 = new Uint8Array(mem.buffer);
          function wasm_hash(hashImpl, str) {
            let ptr = alloc(str.length);
            for (let i = 0; i < str.length; ++i) {
              mem8[ptr + i] = str.charCodeAt(i);
            }

            let hash = hashImpl(ptr, str.length);
            free(ptr);
            return hash;
          }

          assert.equal(wasm_hash(adler32, "test"), 73204161);
          assert.equal(wasm_hash(adler32v2, "test"), 73204161);
        }
      )
  ];
};
