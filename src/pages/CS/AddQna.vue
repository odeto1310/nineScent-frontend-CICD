<template>
  <div v-if="!isLoading">
    <h1>Qna form</h1>
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
        <p>{{ itemData.itemName }} {{ itemData.itemSize }}ml</p>
        <p>{{ priceText }}</p>
      </div>
    </div>
    <div class="category-container">
      <div class="category-title">문의 유형</div>
      <div>
        <select class="category" v-model="qnaData.qnaCategory">
          <option v-for="category in categories" :key="category" :value="category">
            {{ category }}
          </option>
        </select>
      </div>
    </div>
    <br />
    <div class="title-container">
      <div class="title-title">제목 (필수)</div>
      <input
        class="title"
        type="text"
        v-model="qnaData.title"
        placeholder="제목을 입력해주세요"
      /><br />
    </div>
    <textarea
      class="content"
      type="text"
      v-model="qnaData.content"
      placeholder="문의할 내용을 입력해주세요"
    /><br />
    <div class="img-container">
      <input type="file" />
    </div>
    <div class="add-qna">
      <button class="cancel-btn" @click="cancel">취소</button>
      <button class="add-btn" @click="submitQna">등록</button>
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

const categories = ref(['배송', '재입고', '상품상세문의']);

const qnaData = ref({
  itemId: 0,
  userNo: 0,
  qnaCategory: '배송',
  content: '',
  attachment: '',
  isDone: false,
  createdDate: '',
});

const itemData = ref({
  itemName: '',
  itemSize: '',
  discountRate: 0,
  discountedPrice: 0,
  mainPhoto: '',
});

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

const itemId = route.params.itemId;
const questionId = route.params.questionId;

const fetchItemData = async () => {
  if (!itemId) return;
  isLoading.value = true;
  try {
    const response = await itemApi.getItemById(itemId);
    itemData.value = response;
    qnaData.value.itemId = itemId;
  } catch (error) {
    console.error('Error fetching item data', error);
  } finally {
    isLoading.value = false;
  }
};

const fetchQnaData = async () => {
  const questionId = route.params.questionId;
  if (!questionId) return;
  try {
    const response = await faqnaReviewApi.getQnaById(questionId);
    qnaData.value = response;
  } catch (error) {
    console.error('Error fetching Qna data', error);
  }
};

const submitQna = async () => {
  if (!qnaData.value.qnaCategory || !qnaData.value.content) {
    alert('모든 정보를 입력해주세요');
    return;
  }

  qnaData.value.createdDate = new Date().toISOString();
  if (qnaData.value.attachment === '') {
    qnaData.value.attachment = '없음';
  }

  try {
    if (questionId) {
      // 수정 모드
      await faqnaReviewApi.putQna(questionId, qnaData.value);
    } else {
      // 등록 모드
      await faqnaReviewApi.postQna(qnaData.value);
    }
    router.push({ name: 'ItemDetail', params: { id: itemId } });
  } catch (error) {
    console.error('Error submitting Qna', error);
  }
};

const cancel = async () => {
  if (!confirm('작성을 취소하시겠습니까?')) return;
  router.push({ name: 'ItemDetail', params: { id: itemId } });
};

onMounted(() => {
  fetchItemData();
  fetchQnaData();
  authStore.loadStoredToken();

  const getUserNo = localStorage.getItem('userNo');
  if (getUserNo) {
    qnaData.value.userNo = parseInt(getUserNo);
  }
});
</script>

<style scoped>
.item-container {
  display: flex;
  margin: 20px 0px;
  border-top: 2px solid #000000;
  border-bottom: 1px solid #000000;
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

.title-container {
  display: flex;
  align-items: center;
  width: 100%;
}

.category-container {
  display: flex;
  align-items: center;
  width: 100%;
}

.title-title {
  text-align: center;
  width: 100px;
  margin-right: 20px;
  flex-shrink: 0;
}

.category-title {
  text-align: center;
  width: 100px;
  margin-right: 20px;
}

.category {
  padding: 8px;
  /* margin-top: 10px; */
  border-radius: 5px;
}

.title {
  flex-grow: 1;
  padding: 8px;
  margin-top: 10px;
  margin-bottom: 10px;
  border: 1px solid #000000;
  border-radius: 5px;
}

.content {
  width: 100%;
  height: 200px;
  padding: 8px;
  margin-top: 10px;
  margin-bottom: 10px;
  border-radius: 5px;
}

.add-qna {
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
