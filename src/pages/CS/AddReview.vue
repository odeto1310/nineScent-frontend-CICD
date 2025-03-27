<template>
  <div v-if="!isLoading">
    <h1>Review form</h1>
    <div class="item-container">
      <div class="item-photo">
        <!-- <p>{{ itemData.mainPhoto }}</p> -->
        <img
          v-if="itemData.mainPhoto"
          :src="itemData.mainPhoto"
          class="main-image"
          alt="Product Image"
        />
      </div>
      <div class="item-info">
        <p>{{ itemData.itemName }} {{ itemData.itemSize }}</p>
        <p>{{ priceText }}</p>
      </div>
    </div>
    <div class="star-rating">
      <i
        v-for="i in 5"
        :key="i"
        :class="i <= reviewData.rating ? 'fa-solid fa-star' : 'fa-regular fa-star'"
        @click="setRating(i)"
      ></i>
    </div>
    <hr />
    <h5 class="content-title">어떤 점이 좋았나요?</h5>
    <br />
    <textarea
      class="content"
      type="text"
      v-model="reviewData.content"
      placeholder="후기 내용을 입력해주세요"
    /><br />
    <div class="img-container">
      <input type="file" />
    </div>
    <div class="add-review">
      <button class="cancel-btn" @click="cancel">취소</button>
      <button class="add-btn" @click="submitReview">등록</button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
import faqnaReviewApi from '@/api/faqnaReviewApi';
import itemApi from '@/api/itemApi';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();
const isLoading = ref(true);

const reviewData = ref({
  itemId: 0,
  userNo: 0,
  rating: 0,
  content: '',
  attachment: '',
  createdDate: '',
});

const itemData = ref({
  itemName: '',
  itemSize: '',
  discountRate: 0,
  discountedPrice: 0,
  mainPhoto: '',
});

const itemId = route.params.itemId;
const reviewId = route.params.reviewId;

const setRating = (rating) => {
  reviewData.value.rating = rating;
};

const formattedPrice = computed(() => {
  return itemData.value.discountedPrice
    ? itemData.value.discountedPrice.toLocaleString()
    : itemData.value.price.toLocaleString();
});

const priceText = computed(() => {
  return itemData.value.discountRate > 0
    ? `${itemData.value.discountRate}% ${formattedPrice.value}원`
    : `${formattedPrice.value}원`;
});

const fetchItemData = async () => {
  console.log('itemId', itemId);

  if (!itemId) return;
  isLoading.value = true;
  try {
    const response = await itemApi.getItemById(itemId);
    itemData.value = response;
    console.log('itemData', itemData.value);

    reviewData.value.itemId = itemId;
  } catch (error) {
    console.error('Error fetching item data', error);
  } finally {
    isLoading.value = false;
  }
};

const fetchReviewData = async () => {
  const reviewId = route.params.reviewId;
  console.log('reviewId', reviewId);

  if (!reviewId) return;
  try {
    const response = await faqnaReviewApi.getReviewById(reviewId);
    reviewData.value = response;
  } catch (error) {
    console.error('Error fetching Review data', error);
  }
};

const submitReview = async () => {
  if (!reviewData.value.rating || !reviewData.value.content) {
    alert('모든 정보를 입력해주세요');
    return;
  }

  reviewData.value.createdDate = new Date().toISOString();
  if (reviewData.value.attachment === '') {
    reviewData.value.attachment = '없음';
  }

  try {
    if (reviewId) {
      // 수정 모드
      await faqnaReviewApi.putReview(reviewId, reviewData.value);
    } else {
      // 등록 모드
      await faqnaReviewApi.postReview(reviewData.value);
    }
    router.push({ name: 'ItemDetail', params: { id: itemId } });
  } catch (error) {
    console.error('Error submitting Review', error);
  }
};

const cancel = async () => {
  if (!confirm('작성을 취소하시겠습니까?')) return;
  router.push({ name: 'ItemDetail', params: { id: itemId } });
};

onMounted(() => {
  fetchItemData();
  fetchReviewData();
  authStore.loadStoredToken();

  const getUserNo = localStorage.getItem('userNo');
  if (getUserNo) {
    reviewData.value.userNo = parseInt(getUserNo);
  }
});
</script>

<style scoped>
.item-container {
  display: flex;
  margin: 20px 0px 0px 0px;
  border-top: 2px solid #000000;
  /* border-bottom: 1px solid #000000; */
  padding: 15px;
}

.item-photo {
  width: 100px;
  height: 100px;
  margin-right: 10px;
  overflow: hidden;
}

.item-photo img {
  max-width: 100%;
  max-height: 100%;
  width: auto;
  height: auto;
  object-fit: contain;
}

.star-rating {
  display: flex;
  gap: 5px;
  font-size: 24px;
  color: rgb(255, 204, 0); /* 별 색상 */
  cursor: pointer;
  margin-left: 15px;
}

.star-rating i {
  transition: transform 0.2s;
}

.star-rating i:hover {
  transform: scale(1.2); /* 마우스 오버 시 확대 */
}

.content-title {
  margin-top: 20px;
  margin-bottom: 0px;
}

.content {
  width: 100%;
  height: 200px;
  padding: 8px;
  /* margin-top: 10px; */
  margin-bottom: 10px;
  border-radius: 5px;
}

.add-review {
  text-align: right;
  cursor: pointer;
}

.add-btn {
  border-radius: 5px;
  padding: 4px 15px;
  background: #ffffff;
}

.add-btn:hover {
  background: #f0f0f0;
}

.cancel-btn {
  border-radius: 5px;
  padding: 4px 15px;
  background: #ffffff;
  margin-right: 10px;
}

.cancel-btn:hover {
  background: #f0f0f0;
}
</style>
