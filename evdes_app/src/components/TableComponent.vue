<template>
  <div class="p-4 mb-4 bg-green-200 rounded-lg overflow-clip" v-for="(items, year) in groupedByYear" :key="year">
    <div class="flex items-center justify-between max-md:flex-col max-md:items-start max-md:gap-3">
      <div class="p-1 rounded shadow-md bg-green-500">
        <h2 class="text-3xl font-bold text-black max-md:text-2xl">{{ year }}</h2>
      </div>
      <div class="flex items-center gap-3 max-md:w-full max-md:flex-wrap max-md:gap-2">
        <button
          class="px-4 py-2 bg-green-500 hover:bg-green-100 hover:text-black text-white font-semibold rounded shadow-md focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75 max-md:w-full">
          Raport
        </button>
        <ExcelDownloader :wasteList="wasteList" :year="year" />
        <TemplateExcelDownloader
          :wasteList="wasteList"
          :year="year" />
      </div>
    </div>

    <div class="pt-3 overflow-x-auto">
      <table class="pb-2 min-w-full border border-gray-300 bg-white rounded-lg shadow-md">
        <thead>
          <tr>
            <th class="px-4 py-3 border-b font-semibold text-center text-black w-20">Luna</th>
            <th class="px-4 py-3 border-b font-semibold text-center text-black w-40">Cod deseu</th>
            <th class="px-4 py-3 border-b font-semibold text-center text-black w-20">Generat</th>
            <th class="px-4 py-3 border-b font-semibold text-center text-black w-20">Tratat/Eliminat</th>
            <th class="px-4 py-3 border-b font-semibold text-center text-black w-fit">Descriere deseu
            </th>
            <th class="px-4 py-3 border-b font-semibold text-center text-black w-72">Tratare/Eliminare</th>
            <th class="px-4 py-3 border-b font-semibold text-black w-12">Editeaza</th>
            <th class="px-4 py-3 border-b font-semibold text-black w-12">Sterge</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in items" :key="index" class="hover:bg-gray-50">
            <td class="px-4 py-2 border-b text-black text-center">{{ item.month }}</td>
            <td class="px-4 py-2 border-b text-black text-center">{{ item.code }}</td>
            <td class="px-4 py-2 border-b text-black text-center">{{ item.quantity }} {{ item.unit }}</td>
            <td class="px-4 py-2 border-b text-black text-center">{{ disposedQuantityPercent(item) }}</td>
            <td class="px-4 py-2 border-b text-black text-center">{{ item.name }}</td>

            <td class="px-4 py-2 border-b text-black text-center" v-html="formattedOutbound(item)"></td>
            <td class="px-4 py-2 border-b text-black w-12">
              <button @click="openAddModal(item.id, item)"
                class="px-3 py-1 bg-blue-100 hover:bg-blue-600 text-white rounded">
                ✏️
              </button>
            </td>
            <td class="px-4 py-2 border-b text-black w-12">
              <button @click="removeItem(item.id, item)"
                class="px-3 py-1 bg-red-100 hover:bg-red-300 text-white rounded">
                ❌
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

  </div>

  <div class="max-md:mt-3">
    <button
      class="px-4 py-2 float-left bg-green-500 hover:bg-green-100 hover:text-black text-white font-semibold rounded shadow-md focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75 max-md:float-none max-md:w-full"
      @click="openAddModal()">+ Adaugă Raport</button>
  </div>

  <div v-if="isAddModalOpen" class="modal">
    <div class="modal-content">
      <AddWasteForm :year="currentYear" :item="currentItem" :isEdit="isEditMode" @save-item="saveItem"
        @close="isAddModalOpen = false" />
    </div>
  </div>

</template>

<script>
import AddWasteForm from './AddWasteForm.vue';
import ExcelDownloader from './ExcelDownloader.vue';
import TemplateExcelDownloader from './TemplateExcelDownloader.vue';
import * as XLSX from 'xlsx';
import { saveAs } from 'file-saver';

export default {
  components: {
    AddWasteForm,
    ExcelDownloader,
    TemplateExcelDownloader,
  },
  data() {
    return {
      isAddModalOpen: false,
      isEditMode: false,
      currentYear: null,
      currentItem: null,
      currentItemIndex: null,
      wasteList: [
        {
          id: 0,
          code: "105123",
          quantity: 150,
          unit: "Kg",
          name: "Carton",
          month: "Ianuarie",
          year: 2023,
          outbound: {
            Stocat: { quantity: 32, unit: "", storageType: "" },
            Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
            Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
            Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
            Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
          },
        },
        {
          id: 1,
          code: "105123",
          quantity: 150,
          unit: "Kg",
          name: "Carton",
          month: "Ianuarie",
          year: 2024,
          outbound: {
            Stocat: { quantity: 32, unit: "", storageType: "" },
            Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
            Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
            Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
            Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
          },
        },
        {
          id: 2,
          code: "105123",
          quantity: 150,
          unit: "Kg",
          name: "Carton",
          month: "Ianuarie",
          year: 2024,
          outbound: {
            Stocat: { quantity: 32, unit: "", storageType: "" },
            Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
            Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
            Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
            Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
          },
        },
        {
          id: 3,
          code: "105123",
          quantity: 150,
          unit: "Kg",
          name: "Carton",
          month: "Ianuarie",
          year: 2024,
          outbound: {
            Stocat: { quantity: 32, unit: "", storageType: "" },
            Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
            Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
            Valorificat: { quantity: 33, unit: "", operationCode: "", processingCompany: "" },
            Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
          },
        }]
    }
  },
  computed: {
    groupedByYear() {
      return this.wasteList.reduce((acc, item) => {
        if (!acc[item.year]) {
          acc[item.year] = [];
        }
        acc[item.year].push(item);
        return acc;
      }, {});
    }
  },
  methods: {
    disposedQuantityPercent(arg) {
      const total = arg.outbound.Stocat.quantity + arg.outbound.Tratat.quantity + arg.outbound.Transportat.quantity + arg.outbound.Valorificat.quantity + arg.outbound.Eliminat.quantity;
      const percentage = (total / arg.quantity) * 100;
      return `${total} ${arg.unit} (${percentage.toFixed(0)}%)`;
    },
    addItemHandler(newItem) {
      if (this.currentYear) {
        this.wasteList[this.currentYear].push(newItem);
      }
      this.isAddModalOpen = false;
    },
    formattedOutbound(item) {
      const keys = ['Stocat', 'Tratat', 'Transportat', 'Valorificat', 'Eliminat'];
      const initials = ['S', 'T', 'T', 'V', 'E'];

      return keys.map((key, index) => {
        const value = item.outbound[key]?.quantity || 0;
        const percent = ((value / item.quantity) * 100).toFixed(1);
        const isHighlighted = value > 0;
        const details = JSON.stringify(item.outbound[key] || {}, null, 2); // format details

        return `
      <div style="display: inline-block; position: relative;">
        <div 
          class="
            px-3 py-1 m-1 
            text-white 
            font-semibold 
            rounded 
            ${isHighlighted ? 'bg-green-500 hover:bg-green-100 hover:text-black' : 'bg-gray-300'}
          "
          title="${key}: ${value}${item.unit} (${percent}%)"
        >
          ${initials[index]}
        </div>
        <div id="popover-${key}" class="popover" style="display: none;">
          <pre>${details}</pre>
        </div>
      </div>
    `;
      }).join('');
    },
    openAddModal(itemId = null, item = null) {
      this.isEditMode = !!item;
      this.currentItem = item || {
        code: '',
        quantity: '',
        unit: '',
        name: '',
        month: '',
        year: '',
        outbound: {
          Stocat: { quantity: 0, unit: "", storageType: "" },
          Tratat: { quantity: 0, unit: "", treatmentMode: "", treatmentScope: "" },
          Transportat: { quantity: 0, unit: "", meansOfTransportation: "", destination: "" },
          Valorificat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" },
          Eliminat: { quantity: 0, unit: "", operationCode: "", processingCompany: "" }
        }
      };
      this.currentItemId = itemId;
      this.isAddModalOpen = true;
    },
    saveItem(updatedItem) {
      if (this.isEditMode && this.currentItemId !== null) {
        const indexOfAltered = this.wasteList.findIndex(x => x.id == this.currentItemId);
        this.wasteList[indexOfAltered] = updatedItem;
      } else {
        const maxId = Math.max(...this.wasteList.map(o => o.id));
        updatedItem.id = maxId + 1;
        this.wasteList.push(updatedItem);
      }

      this.isAddModalOpen = false;
    },
    removeItem(itemId = null, item = null) {
      const isConfirmed = confirm("Are you sure you want to remove this item?");

      if (isConfirmed) {
        this.currentItemId = itemId;
        const indexOfRemoved = this.wasteList.findIndex(x => x.id == this.currentItemId);

        if (indexOfRemoved > -1) {
          this.wasteList.splice(indexOfRemoved, 1);
        }
      }
    }
  },
};
</script>

<style scoped>
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal-content {
  background-color: white;
  padding: 20px;
  border-radius: 5px;
}

@media (max-width: 768px) {
  .modal {
    align-items: flex-start;
    overflow-y: auto;
    padding: 12px;
  }

  .modal-content {
    width: 100%;
    max-width: 100%;
    margin-top: 12px;
    padding: 14px;
  }
}
</style>
