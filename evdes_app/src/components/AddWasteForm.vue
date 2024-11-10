<template>

    <form @submit.prevent="submitForm">
        <div class="flex flex-col">
            <div class="basis-1/6 mb-4 p-2 bg-green-200 rounded-lg shadow-md flex space-x-3">
                <!-- Select, anul, cantitatea, tipul -->
                <div class="flex-grow">
                    <label class="sttve-label">Cautare</label>
                    <SearchableDropdown @item-selected="updateFormFields" />
                </div>
                <div>
                    <label class="sttve-label">Luna:</label>
                    <select class="sttve-content" v-model="formData.month">
                        <option disabled value="">Selectaza luna</option>
                        <option v-for="(month, index) in months" :key="index" :value="month">
                            {{ month }}
                        </option>
                    </select>
                </div>

                <div>
                    <label class="sttve-label">Anul:</label>
                    <select class="sttve-content" v-model="formData.year">
                        <option disabled value="">Selecteaza anul</option>
                        <option v-for="year in years" :key="year" :value="year">
                            {{ year }}
                        </option>
                    </select>
                </div>

            </div>
            <div class="basis-4/6 flex space-x-3 mb-3">
                <!-- Generare -->
                <div class="sttve">
                    <fieldset>
                        <legend class="valid-legend">Generat</legend>
                        <div>
                            <label class="sttve-label">Cantitate:</label>
                            <input class="sttve-content" v-model.number="formData.quantity" type="number" />
                        </div>
                        <div>
                            <label class="sttve-label">Cod:</label>
                            <input class="sttve-content" v-model="formData.code" />
                        </div>
                        <div>
                            <label class="sttve-label">Unitate de masura</label>
                            <select class="sttve-content" v-model="formData.unit">
                                <option value="kg">Kilograme (kg)</option>
                                <option value="L">Litri (L)</option>
                                <option value="ton">Tone (T)</option>
                                <option value="m3">Meteri Cubi (m³)</option>
                                <option value="g">Grame (g)</option>
                            </select>
                        </div>
                        <div>
                            <label class="sttve-label">Deseu:</label>
                            <input class="sttve-content" v-model="formData.name" />
                        </div>
                    </fieldset>
                </div>
                <!-- Tratare -->
                <div class="sttve">
                    <fieldset>
                        <legend :class="percentageStocat > 100 ? 'invalid-legend' : 'valid-legend'">
                            Stocat: {{ percentageStocat }}%
                        </legend>
                        <div>
                            <label class="sttve-label">Cantitate:</label>
                            <input v-model.number="formData.outbound.Stocat.quantity" type="number"
                                class="sttve-content" />
                        </div>
                        <div>
                            <label class="sttve-label">Unitate de masura:</label>
                            <select v-model="formData.outbound.Stocat.unit" class="sttve-content">
                                <option value="kg">Kilograme (kg)</option>
                                <option value="L">Litri (L)</option>
                                <option value="ton">Tone (T)</option>
                                <option value="m3">Meteri Cubi (m³)</option>
                                <option value="g">Grame (g)</option>
                            </select>
                        </div>
                        <div>
                            <label class="sttve-label">Mod stocare:</label>
                            <input v-model="formData.outbound.Stocat.storageType" type="text" class="sttve-content" />
                        </div>
                        <div class="invisible">
                            <label class="sttve-label">Mod stocare:</label>
                            <input v-model="formData.outbound.Stocat.storageType" type="text" class="sttve-content" />
                        </div>
                    </fieldset>
                </div>
                <div class="sttve">
                    <fieldset>
                        <legend :class="percentageTratat > 100 ? 'invalid-legend' : 'valid-legend'">
                            Tratat: {{ percentageTratat }}%
                        </legend>
                        <div>
                            <label class="sttve-label">Cantitate:</label>
                            <input class="sttve-content" v-model.number="formData.outbound.Tratat.quantity"
                                type="number" />
                        </div>
                        <div>
                            <label class="sttve-label">Unitate de masura:</label>
                            <select class="sttve-content" v-model="formData.outbound.Tratat.unit">
                                <option value="kg">Kilograme (kg)</option>
                                <option value="L">Litri (L)</option>
                                <option value="ton">Tone (T)</option>
                                <option value="m3">Meteri Cubi (m³)</option>
                                <option value="g">Grame (g)</option>
                            </select>
                        </div>
                        <div>
                            <label class="sttve-label">Mod tratare:</label>
                            <input class="sttve-content" v-model="formData.outbound.Tratat.treatmentMode" />
                        </div>
                        <div>
                            <label class="sttve-label">Scop:</label>
                            <input class="sttve-content" v-model="formData.outbound.Tratat.treatmentScope" />
                        </div>
                    </fieldset>
                </div>
                <div class="sttve">
                    <fieldset>
                        <legend :class="percentageTransportat > 100 ? 'invalid-legend' : 'valid-legend'">
                            Transportat: {{ percentageTransportat }}%
                        </legend>
                        <div>
                            <label class="sttve-label">Cantitate:</label>
                            <input class="sttve-content" v-model.number="formData.outbound.Transportat.quantity"
                                type="number" />
                        </div>
                        <div>
                            <label class="sttve-label">Unitate de masura:</label>
                            <select class="sttve-content" v-model="formData.outbound.Transportat.unit">
                                <option value="kg">Kilograme (kg)</option>
                                <option value="L">Litri (L)</option>
                                <option value="ton">Tone (T)</option>
                                <option value="m3">Meteri Cubi (m³)</option>
                                <option value="g">Grame (g)</option>
                            </select>
                        </div>
                        <div>
                            <label class="sttve-label">Mijloc:</label>
                            <input class="sttve-content"
                                v-model="formData.outbound.Transportat.meansOfTransportation" />
                        </div>
                        <div>
                            <label class="sttve-label">Destinatie:</label>
                            <input class="sttve-content" v-model="formData.outbound.Transportat.destination" />
                        </div>
                    </fieldset>
                </div>
                <div class="sttve">
                    <fieldset>
                        <legend :class="percentageValorificat > 100 ? 'invalid-legend' : 'valid-legend'">
                            Valorificat: {{ percentageValorificat }}%
                        </legend>
                        <div>
                            <label class="sttve-label">Cantitate:</label>
                            <input class="sttve-content" v-model.number="formData.outbound.Valorificat.quantity" />
                        </div>
                        <div>
                            <label class="sttve-label">Unitate de masura:</label>
                            <select class="sttve-content" v-model="formData.outbound.Valorificat.unit">
                                <option value="kg">Kilograme (kg)</option>
                                <option value="L">Litri (L)</option>
                                <option value="ton">Tone (T)</option>
                                <option value="m3">Meteri Cubi (m³)</option>
                                <option value="g">Grame (g)</option>
                            </select>
                        </div>
                        <div>
                            <label class="sttve-label">Cod operatie:</label>
                            <input class="sttve-content" v-model="formData.outbound.Valorificat.operationCode" />
                        </div>
                        <div>
                            <label class="sttve-label">Procesator:</label>
                            <input class="sttve-content" v-model="formData.outbound.Valorificat.processingCompany" />
                        </div>
                    </fieldset>
                </div>
                <div class="sttve">
                    <fieldset>
                        <legend :class="percentageEliminat > 100 ? 'invalid-legend' : 'valid-legend'">
                            Eliminat: {{ percentageEliminat }}%
                        </legend>
                        <div>
                            <label class="sttve-label">Cantitate:</label>
                            <input class="sttve-content" v-model.number="formData.outbound.Eliminat.quantity"
                                type="number" />
                        </div>
                        <div>
                            <label class="sttve-label">Unitate de masura:</label>
                            <select class="sttve-content" v-model="formData.outbound.Eliminat.unit">
                                <option value="kg">Kilograme (kg)</option>
                                <option value="L">Litri (L)</option>
                                <option value="ton">Tone (T)</option>
                                <option value="m3">Meteri Cubi (m³)</option>
                                <option value="g">Grame (g)</option>
                            </select>
                        </div>
                        <div>
                            <label class="sttve-label">Cod operatie:</label>
                            <input class="sttve-content" v-model="formData.outbound.Eliminat.operationCode" />
                        </div>
                        <div>
                            <label class="sttve-label">Procesator:</label>
                            <input class="sttve-content" v-model="formData.outbound.Eliminat.processingCompany" />
                        </div>
                    </fieldset>
                </div>
            </div>
            <div class="basis-1/6 flex">
                <!-- OK/NOK -->
                <button
                    class="px-4 py-2 bg-green-500 hover:bg-green-100 hover:text-black text-white font-semibold rounded shadow-md focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75"
                    type="submit" @click="submitForm()">{{ isEdit ? 'Editeaza' : 'Adauga' }} deseu | {{
                        averagePercentage }}%</button>
                <button
                    class="px-4 py-2 ml-2 bg-green-500 hover:bg-green-100 hover:text-black text-white font-semibold rounded shadow-md focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75"
                    type="button" @click="$emit('close')">Inapoi</button>
                <div class="px-4 py-2 rounded  ml-2 flex-grow text-right">
                    <span class="text-gray-800 cursor-text" v-text="errorMessage"></span>
                </div>
            </div>
        </div>
    </form>
</template>

<script>
import { errorMessages } from 'vue/compiler-sfc';
import SearchableDropdown from './SearchableDropdown.vue';
import { reactive, toRaw } from 'vue';

export default {
    components: {
        SearchableDropdown
    },
    props: {
        item: {
            type: Object,
            default: () => ({}),
        },
        isEdit: {
            type: Boolean,
            default: false,
        },
    },
    computed: {
        years() {
            const currentYear = new Date().getFullYear();
            const startYear = currentYear - 15;
            const endYear = currentYear + 5;
            const years = [];
            for (let year = startYear; year <= endYear; year++) {
                years.push(year);
            }
            return years;
        },
        percentageStocat() {
            return this.calculatePercentage(this.formData.outbound.Stocat.quantity);
        },
        percentageTratat() {
            return this.calculatePercentage(this.formData.outbound.Tratat.quantity);
        },
        percentageTransportat() {
            return this.calculatePercentage(this.formData.outbound.Transportat.quantity);
        },
        percentageValorificat() {
            return this.calculatePercentage(this.formData.outbound.Valorificat.quantity);
        },
        percentageEliminat() {
            return this.calculatePercentage(this.formData.outbound.Eliminat.quantity);
        },
        averagePercentage() {
            const total =
                parseFloat(this.percentageStocat) +
                parseFloat(this.percentageTratat) +
                parseFloat(this.percentageTransportat) +
                parseFloat(this.percentageValorificat) +
                parseFloat(this.percentageEliminat);
            return total.toFixed(0);
        }
    },
    watch: {
        'formData.unit': function (newUnit) {
            this.changeUnit(newUnit);
        }
    },
    data() {
        return {
            formData: { ...this.item },
            months: [
                "Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie",
                "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"
            ],
            errorMessage: '',
            disposalPercentage: ''
        };
    },
    methods: {
        calculatePercentage(quantity) {
            const generated = this.formData.quantity;
            return generated > 0 ? ((quantity / generated) * 100).toFixed(0) : 0;
        },
        // Update form fields based on the selected dropdown item
        updateFormFields(selectedItem) {
            this.formData.code = selectedItem.code;
            this.formData.name = selectedItem.description;
        },
        validate() {
            if (this.formData.month == '') { this.errorMessage = 'Alegeti luna'; return ''; }
            if (this.formData.year == '') { this.errorMessage = 'Alegeti anul'; return ''; }
            if (this.formData.quantity == '') { this.errorMessage = 'Alegeti cantitatea generata'; return ''; }
            if (this.formData.quantity < 0) { this.errorMessage = 'Cantitatea nu poate fi negativa'; return ''; }

            if (this.formData.code == '') { this.errorMessage = 'Alegeti codul deseului'; return ''; }
            if (this.formData.unit == '') { this.errorMessage = 'Alegeti unitatea de masura'; return ''; }
        },
        submitForm() {
            if (this.validate() != undefined) { return };
            this.$emit('save-item', { ...this.formData });
        },
        changeUnit(newUnit) {
            const rawFormData = toRaw(this.formData);  // Convert formData to its raw (non-reactive) form

            rawFormData.unit = newUnit;
            rawFormData.outbound.Stocat.unit = newUnit;
            rawFormData.outbound.Tratat.unit = newUnit;
            rawFormData.outbound.Transportat.unit = newUnit;
            rawFormData.outbound.Valorificat.unit = newUnit;
            rawFormData.outbound.Eliminat.unit = newUnit;

            this.formData = reactive(rawFormData);  // Apply the changes back
        }
    }
};
</script>

<style scoped>
.sttve {
    @apply p-2 bg-green-200 rounded-lg shadow-md w-48;
}

.sttve-label {
    @apply block text-sm font-medium text-gray-600 mb-1;
}

.sttve-content {
    @apply w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500;
}

.valid-legend {
    @apply text-sm font-semibold px-2 text-gray-700;
}

.invalid-legend {
    @apply text-sm font-semibold px-2 text-red-700;
}

fieldset {
    @apply border border-gray-300 p-4 rounded-md shadow-sm;
}
</style>