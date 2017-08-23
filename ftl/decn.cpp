//#define _CRT_SECURE_NO_WARNINGS
#include <cstdio>
#include <cstdint>
#include <memory>
#include <string.h>
#include <map>
#include <list>
#include <vector>
#include <set>
#include <algorithm>

typedef uint8_t u8;
typedef uint32_t u32;
typedef uint64_t u64;

// Logical
#define BYTES_PER_SECTOR 512

// Physical
#define BYTES_PER_PAGE 0x1000
#define NUM_PLANES 2
#define BYTES_PER_PAGE_PER_PLANE (BYTES_PER_PAGE / NUM_PLANES)
#define PAGES_PER_BLOCK 64
#define BYTES_PER_BLOCK (BYTES_PER_PAGE * PAGES_PER_BLOCK)

/*
starting from 0x5a80000 there are 1686 blocks of 0x40000
*/
struct PageMapping
{
  u64 block;
  u64 page;
};

std::unique_ptr<u8[]> read_page(u8 *buf, const PageMapping &mapping)
{
  size_t per_plane_len = BYTES_PER_PAGE_PER_PLANE;
  size_t block_len = BYTES_PER_BLOCK;
  auto page = std::make_unique<u8[]>(BYTES_PER_PAGE);
  if (mapping.block == 0xffff || mapping.page == 0xffff)
  {
    memset(&page[0], 0xff, BYTES_PER_PAGE);
    return page;
  }

  auto block = &buf[block_len * mapping.block];
  for (int plane = 0; plane < NUM_PLANES; plane++)
  {
    auto page_src = &block[per_plane_len * (plane * PAGES_PER_BLOCK + mapping.page)];
    memcpy(&page[plane * per_plane_len], page_src, per_plane_len);
  }

  return page;
}

void dump_logical(u8 *buf, u64 len) {
  // should be (len - 0x5a80000) / 0x40000 * 64 == 0x1a580, but really 0x1b000, so rounded?
  auto page_map = std::vector<PageMapping>(0x1b100, { 0xffff, 0xffff });

  for (u64 pos = 0x5a80000, block = 0; pos < len; pos += BYTES_PER_BLOCK, block++)
  {
    // hack: don't translate, just directly read the sector containing logical map info
    auto info = (u32 *)&buf[pos + 0x1f800];
    for (u32 page = 0; page < PAGES_PER_BLOCK - 1; page++, info++)
    {
      u32 index=*info;
      if(index>=0x1b100)
      {
        printf("ind:\t%x\n",index);
        continue;
      }
      auto existing = page_map[index];
      if (existing.block != 0xffff)
      {
        // TODO choose which to use
        printf("dupe ind:\t%x\n",index);
        continue;
      }
      page_map[index] = { block, page };
    }
  }

  FILE *f = fopen("./logical.bin", "wb");
  for (const auto &p : page_map)
  {
    auto page = read_page(&buf[0x5a80000], p);
    fwrite(&page[0], BYTES_PER_PAGE, 1, f);
  }
  fclose(f);
}

int main(int argc, char **argv)
{
  const char *fname = "./nand_fel_full.bin";
  if (argc > 1 && argv[1])
  {
    fname = argv[1];
  }
  FILE *f = fopen(fname, "rb");
  fseek(f, 0, SEEK_END);
  auto f_len = ftell(f);
  fseek(f, 0, SEEK_SET);
  auto f_buf = std::make_unique<uint8_t[]>(f_len);
  fread(f_buf.get(), f_len, 1, f);
  fclose(f);

  dump_logical(f_buf.get(), f_len);
  //decrypt_file("./rootfs.bin");
  return 0;
}
