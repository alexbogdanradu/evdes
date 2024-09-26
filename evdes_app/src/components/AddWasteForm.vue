<template>
    <div class="add-item-form">
        <SearchableDropdown @item-selected="updateFormFields" />
        <h3>Adauga deseu</h3>
        <form @submit.prevent="submitForm">
            <div>
                <label>Cod:</label>
                <input v-model="formData.code" />
            </div>
            <div>
                <label>Cantitate:</label>
                <input v-model.number="formData.quantity" type="number" />
            </div>
            <div>
                <label>Unitate de masura</label>
                <input v-model="formData.unit" />
            </div>
            <div>
                <label>Deseu:</label>
                <input v-model="formData.name" />
            </div>
            <div>
                <label>Luna:</label>
                <input v-model="formData.month" />
            </div>
            <div>
                <label>Anul:</label>
                <input v-model="formData.year" type="number" />
            </div>
            <fieldset>
                <legend>Stocat</legend>
                <div>
                    <label>Cantitate:</label>
                    <input v-model.number="formData.outbound.Stocat.quantity" type="number" />
                </div>
                <div>
                    <label>Unitate de masura:</label>
                    <input v-model="formData.outbound.Stocat.unit" />
                </div>
                <div>
                    <label>Mod stocare:</label>
                    <input v-model="formData.outbound.Stocat.storageType" />
                </div>
            </fieldset>
            <fieldset>
                <legend>Tratat</legend>
                <div>
                    <label>Cantitate:</label>
                    <input v-model.number="formData.outbound.Tratat.quantity" type="number" />
                </div>
                <div>
                    <label>Unitate de masura:</label>
                    <input v-model="formData.outbound.Tratat.unit" />
                </div>
                <div>
                    <label>Mod tratare:</label>
                    <input v-model="formData.outbound.Tratat.treatmentMode" />
                </div>
                <div>
                    <label>Scop:</label>
                    <input v-model="formData.outbound.Tratat.treatmentScope" />
                </div>
            </fieldset>
            <fieldset>
                <legend>Transportat</legend>
                <div>
                    <label>Quantity:</label>
                    <input v-model.number="formData.outbound.Transportat.quantity" type="number" />
                </div>
                <div>
                    <label>Unitate de masura:</label>
                    <input v-model="formData.outbound.Transportat.unit" />
                </div>
                <div>
                    <label>Mijloc:</label>
                    <input v-model="formData.outbound.Transportat.meansOfTransportation" />
                </div>
                <div>
                    <label>Destinatie:</label>
                    <input v-model="formData.outbound.Transportat.destination" />
                </div>
            </fieldset>
            <fieldset>
                <legend>Valorificat</legend>
                <div>
                    <label>Cantitate:</label>
                    <input v-model.number="formData.outbound.Valorificat.quantity" type="number" />
                </div>
                <div>
                    <label>Unitate de masura:</label>
                    <input v-model="formData.outbound.Valorificat.unit" />
                </div>
                <div>
                    <label>Cod operatie:</label>
                    <input v-model="formData.outbound.Valorificat.operationCode" />
                </div>
                <div>
                    <label>Procesator:</label>
                    <input v-model="formData.outbound.Valorificat.processingCompany" />
                </div>
            </fieldset>
            <fieldset>
                <legend>Eliminat</legend>
                <div>
                    <label>Cantitate:</label>
                    <input v-model.number="formData.outbound.Eliminat.quantity" type="number" />
                </div>
                <div>
                    <label>Unitate de masura:</label>
                    <input v-model="formData.outbound.Eliminat.unit" />
                </div>
                <div>
                    <label>Cod operatie:</label>
                    <input v-model="formData.outbound.Eliminat.operationCode" />
                </div>
                <div>
                    <label>Procesator:</label>
                    <input v-model="formData.outbound.Eliminat.processingCompany" />
                </div>
            </fieldset>
            <button type="submit" @click="submitForm()">{{ isEdit ? 'Editeaza' : 'Adauga' }} deseu</button>
            <button type="button" @click="$emit('close')">Cancel</button>
        </form>
    </div>
</template>

<script>
import SearchableDropdown from './SearchableDropdown.vue';

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
    watch: {
        item: {
            handler(newValue) {
                this.formData = { ...newValue };
            },
            deep: true,
            immediate: true
        }
    },
    data() {
        return {
            formData: { ...this.item }
        };
    },
    methods: {
        // Update form fields based on the selected dropdown item
        updateFormFields(selectedItem) {
            this.formData.code = selectedItem.code;
            this.formData.name = selectedItem.description;
        },
        submitForm() {
            this.$emit('save-item', { ...this.formData });
        }
    }
};
</script>

<style scoped>
/* Add basic styling for form */
</style>