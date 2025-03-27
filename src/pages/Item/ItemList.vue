<template>
  <div v-if="!isLoading">
    <div>
      <div class="img-header">
        <img class="header" src="@/assets/images/l1.png" alt="banner" />
        <img class="header" src="@/assets/images/l2.png" alt="banner" />
        <img class="header" src="@/assets/images/l3.png" alt="banner" />
      </div>
      <div class="grid-container">
        <div
          v-for="(item, index) in items"
          :key="item.itemId"
          class="grid-item"
          @click="selectItem(item.itemId)"
          @mouseover="setHover(index, true)"
          @mouseleave="setHover(index, false)"
        >
          <!-- <img :src="item.imageUrl" :alt="item.itemName" class="item-image" /> -->
          <!-- <img class="item-image" src="@/assets/images/product1.jpg" alt="" /> -->
          <!-- <img :src="hoverIndex === index && item.mainPhoto ? item.mainPhoto : defaultImage" :alt="item.itemName" class="item-image" /> -->
          <div class="image-wrapper">
            <img :src="defaultImage" :alt="item.itemName" class="item-image default" />
            <img
              :src="item.mainPhoto"
              :alt="item.itemName"
              class="item-image hover"
              :class="{ active: hoverIndex === index }"
            />
          </div>
  
          <p class="item-name">{{ item.itemName }} {{ item.itemSize }}</p>
          <p class="item-price">{{ priceText(item) }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';
import itemApi from '@/api/itemApi';
import defaultImage from '@/assets/images/product1.jpg';

const router = useRouter();
const isLoading = ref(true);
const items = ref([]);

const hoverIndex = ref(null);

// const hoverImage =

const fetchItems = async () => {
  isLoading.value = true;
  try {
    const response = await itemApi.getItems();
    items.value = response;
  } catch (error) {
    console.error('Error fetching list', error.message);
  } finally {
    isLoading.value = false;
  }
};

const selectItem = (itemId) => {
  router.push({ name: 'ItemDetail', params: { id: itemId } });
};

const formattedPrice = (price) => {
  return price.toLocaleString();
};

const priceText = (item) => {
  if (item.discountRate > 0 && item.discountRate !== null) {
    return `${item.discountRate}% ${formattedPrice(item.discountedPrice)}원`;
  } else {
    return `${formattedPrice(item.price)}원`;
  }
};

const setHover = (index, isHovered) => {
  hoverIndex.value = isHovered ? index : null;
};

onMounted(() => {
  fetchItems();
});
</script>

<style scoped>
.grid-container {
  display: grid;
  gap: 16px;
  padding: 30px;
  grid-template-columns: repeat(2, 1fr);
}

@media (min-width: 900px) {
  .grid-container {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (min-width: 1200px) {
  .grid-container {
    grid-template-columns: repeat(4, 1fr);
  }
}

.grid-item {
  /* border: 1px solid #ddd;
  border-radius: 8px; */
  /* padding: 16px; */
  text-align: center;
  cursor: pointer;
  transition: transform 0.2s ease-in-out;
}

.grid-item:hover {
  /* box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); */
  box-shadow: none !important;
  background-color: transparent !important;
  transform: none !important;
}

.image-wrapper {
  position: relative;
  width: 100%;
  height: auto;
  min-height: 220px;

  overflow: hidden;
  aspect-ratio: 1/1;
}

.item-image {
  width: 100%;
  height: auto;
  /* max-height: 400px; */
  object-fit: cover;
  transition: opacity 0.3s ease-in-out;
}

/* 기본 이미지 */
.default {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 1;
  z-index: 1;
}

/* 호버 이미지 (초기에는 숨김) */
.hover {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0;
  z-index: 2;
}

/* 호버 시 활성화 */
.hover.active {
  opacity: 1;
}

@media (min-width: 900px) {
  .item-image {
    max-height: 350px;
  }
}

@media (min-width: 1200px) {
  .item-image {
    max-height: 400px;
  }
}

.item-name {
  margin-top: 15px;
}

.img-header {
  display: flex;
  justify-content: space-between;
  padding: 50px;
  background-color: #eff0eb;
  margin-top: -20px;
  margin-left: -20px;
  margin-right: -20px;
  margin-bottom: 20px;
}

.header {
  width: 28%;
  height: auto;
  border-radius: 10px;
}
</style>
