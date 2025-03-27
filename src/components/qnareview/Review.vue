<template>
  <div v-if="!isLoading">
    <div>
      <div class="rating-header">
        <p class="rating-text1">실제 구매한 고객님께서 작성해주셨어요.</p>
        <p class="rating-text2">리뷰 작성시 적립금을 드립니다.</p>
      </div>
      <div class="rating-container">
        <div class="rating">
          <div>{{ rating }}/5</div>
          <div class="stars">
            <span v-for="i in 5" :key="i" class="star">
              <i v-if="i <= Math.floor(rating)" class="fa-solid fa-star full"></i>
              <i
                v-else-if="i === Math.ceil(rating) && rating % 1 !== 0"
                class="fa-solid fa-star half"
                :style="getStarStyle(rating % 1)"
              ></i>
              <i v-else class="fa-regular fa-star empty"></i>
            </span>
          </div>
          <div>{{ reviews.totalElements }}개의 후기</div>
        </div>
        <div class="rating-chart">
          <BarChart :ratingCounts="ratingCounts" />
        </div>
      </div>
      <div class="review-header">
        <div class="title">REVIEW ({{ reviews.totalElements }})</div>
        <div class="add-review">
          <button class="add-btn" @click="addReview(itemId)">리뷰등록</button>
        </div>
      </div>
      <div class="review-container">
        <p class="no-content" v-if="reviews.content.length === 0">등록된 후기가 없습니다.</p>
        <ul class="review-list" v-else>
          <li v-for="review in reviews.content" :key="review.reviewId" class="review">
            <div>
              <p class="content-title">{{ review.name }} {{ formatDate(review.createdDate) }}</p>
              <p class="content-rate">
                <span v-for="i in 5" :key="i">
                  <i v-if="i <= review.rating" class="fa-solid fa-star"></i>
                  <i v-else class="fa-regular fa-star"></i>
                </span>
              </p>
              <!-- <p>{{ review.reviewImage }}</p> -->
              <span>
                <img class="review-image" src="@/assets/images/product2.jpg" alt="" />
              </span>

              <p class="content-content">{{ review.content }}</p>
            </div>
            <div v-if="isReviewOwner(review)">
              <span class="update" @click="editReview(review)">수정</span>
              <span class="delete" @click.stop="deleteReview(review.reviewId)">삭제</span>
            </div>
          </li>
        </ul>
        <template v-if="reviews.content.length > 0">
          <div class="paginate">
            <vue-awesome-paginate
              :total-items="reviews.totalElements"
              :items-per-page="reviews.pageable.pageSize"
              :max-pages-shown="reviews.totalPages"
              :show-ending-buttons="false"
              v-model="currentPage"
              @click="handlePageChange"
            >
              <template #first-page-button><i class="fa-solid fa-backward-fast"></i></template>
              <template #prev-button><i class="fa-solid fa-caret-left"></i></template>
              <template #next-button><i class="fa-solid fa-caret-right"></i></template>
              <template #last-page-button><i class="fa-solid fa-forward-fast"></i></template>
            </vue-awesome-paginate>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, reactive } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
import faqnaReviewApi from '@/api/faqnaReviewApi';
import BarChart from '@/components/chart/BarChart.vue';

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();

const reviews = ref({
  content: [],
  pageable: { pageNumber: 0, pageSize: 5 },
  totalElements: 0,
  totalPages: 0,
});
const rating = ref(0);
const isLoading = ref(true);
const ratingCounts = ref({ 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 });

let userNo = 0;
const itemId = route.params.id;

const isLogin = ref(false);

const isReviewOwner = (review) => {
  console.log('userNo', userNo);
  console.log(review.userNo);

  return review.userNo === userNo;
};

const currentPage = ref(1);
const pageRequest = ref({ page: 0 });

const handlePageChange = async (page) => {
  currentPage.value = page;
  pageRequest.value.page = page - 1;
  await fetchReviewData();
};

const fetchReviewData = async () => {
  if (!itemId) return;
  isLoading.value = true;
  try {
    const response = await faqnaReviewApi.getReviewPage(itemId, pageRequest.value.page);
    reviews.value = response;

    if (reviews.value.pageable) {
      currentPage.value = reviews.value.pageable.pageNumber + 1;
    }
    console.log('reviews', reviews.value);
  } catch (error) {
    console.error('Error fetching review data', error);
  } finally {
    isLoading.value = false;
  }
};

const formatDate = (date) => {
  if (!date || date.length < 6) return 'N/A';

  const year = String(date[0]).slice(2);
  const month = String(date[1]).padStart(2, '0');
  const day = String(date[2]).padStart(2, '0');

  return `${year}.${month}.${day}`;
};

const addReview = (itemId) => {
  if (!isLogin.value) {
    if (confirm('로그인이 필요한 서비스입니다. 로그인 페이지로 이동하시겠습니까?')) {
      router.push({ name: 'Login' });
    }
    return;
  }
  router.push({ name: 'AddReview', params: { itemId } });
};

const editReview = (review) => {
  router.push({
    name: 'UpdateReview',
    params: { itemId: itemId, reviewId: review.reviewId },
  });
};

const deleteReview = async (reviewId) => {
  if (!confirm('정말 삭제하시겠습니까?')) return;
  try {
    await faqnaReviewApi.deleteReview(reviewId);
    fetchReviewData();
  } catch (error) {
    console.error('Error deleting review', error);
  }
};

const getRating = async () => {
  try {
    const response = await faqnaReviewApi.getRatingByItemId(itemId);
    rating.value = response;
  } catch (error) {
    console.error('Error fetching rating data', error);
  }
};

const getRatingCounts = async () => {
  try {
    const response = await faqnaReviewApi.getRatingCountsByItemId(itemId);
    ratingCounts.value = response;
  } catch (error) {
    console.error('Error fetching rating counts', error);
  }
};

const getStarStyle = (fraction) => {
  return {
    background: `linear-gradient(90deg, #fa9200 ${fraction * 100}%, #e0e0e0 ${fraction * 100}%)`,
    '-webkit-background-clip': 'text',
    '-webkit-text-fill-color': 'transparent',
  };
};

onMounted(() => {
  fetchReviewData();
  getRating();
  getRatingCounts();
  authStore.loadStoredToken();

  const getUserNo = localStorage.getItem('userNo');
  if (getUserNo) {
    userNo = parseInt(getUserNo);
    isLogin.value = true;
  } else {
    isLogin.value = false;
  }
});
</script>

<style scoped>
.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.rating-header {
  display: flex;
  flex-direction: column;
  justify-content: center;
  text-align: center;
}

.rating-text1 {
  font-size: 20px;
  margin-top: 50px;
}

.rating-text2 {
  font-size: 20px;
}

.rating-container {
  display: flex;
  justify-content: space-between;
  margin-top: 50px;
  margin-bottom: 50px;
}

.rating {
  display: flex;
  width: 50%;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  font-size: 20px;
  font-weight: bold;
  border-right: 1px solid #e0e0e0;
  padding-left: 50px;
}

.rating-chart {
  padding-left: 50px;
  width: 50%;
  height: auto;
}

.review-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
}

.title {
  font-size: 25px;
}

.stars {
  display: flex;
  margin-top: 10px;
}

.star {
  position: relative;
  display: inline-block;
  font-size: 35px;
}

.no-content {
  text-align: center;
  margin: 20px 0px;
}

.review-container {
  margin: 20px 0px;
  border-top: 1px solid #e0e0e0;
  border-bottom: 1px solid #e0e0e0;
}
.review-list {
  margin: 0;
  padding: 0;
}

.review {
  list-style: none;
  border-bottom: 1px solid #ccc;
  padding: 10px;
  display: flex;
  justify-content: space-between;
}

.add-review {
  text-align: right;
}

.add-btn {
  padding: 5px 15px;
  border-radius: 5px;
  background-color: #ffffff;
}

.update {
  margin-right: 10px;
  cursor: pointer;
  color: #8a8a8a;
}

.delete {
  cursor: pointer;
  color: #8a8a8a;
}

.review-image {
  width: 120px;
  height: 130px;
  margin-top: 10px;
  margin-bottom: 10px;
}

.content-title {
  margin-bottom: 0px;
}

.content-rate {
  margin-bottom: 5px;
}

.content-content {
  margin-bottom: 0px;
}

.rate-avg {
  word-spacing: -4px;
}

.fa-star {
  color: #fa9200;
}

.paginate {
  text-align: center;
}
</style>
