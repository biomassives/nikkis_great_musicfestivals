<template>
  <q-page padding>
    <q-card>
      <q-card-section>
        <h4>Donations and Sponsorships</h4>
      </q-card-section>
      <q-card-section>
        <q-form @submit="handleDonation">
          <q-input v-model="donationAmount" label="Donation Amount" type="number" />
          <q-btn type="submit" label="Donate" color="primary" />
        </q-form>
      </q-card-section>
      <q-card-section>
        <h5>Sponsorship Levels</h5>
        <q-list>
          <q-item v-for="level in sponsorshipLevels" :key="level.id">
            <q-item-section>
              <q-item-label>{{ level.name }}</q-item-label>
              <q-item-label caption>{{ level.description }}</q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-btn @click="handleSponsorship(level.id)" label="Sponsor" color="secondary" />
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>
      <q-card-section>
        <h5>Upload Logo for Sponsorship</h5>
        <q-file v-model="logoFile" label="Upload Logo" />
        <q-btn @click="uploadLogo" label="Upload" color="primary" />
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script lang="ts">
import { ref } from 'vue';
import { loadStripe } from '@stripe/stripe-js';

const stripePromise = loadStripe('your-stripe-publishable-key'); // Replace with your Stripe publishable key

export default {
  name: 'DonationsPage',
  setup() {
    const donationAmount = ref<string>('');
    const logoFile = ref<File | null>(null);
    const sponsorshipLevels = ref([
      { id: 1, name: 'Bronze', description: 'Basic sponsorship', price: 1000 },
      { id: 2, name: 'Silver', description: 'Silver sponsorship', price: 2000 },
      { id: 3, name: 'Gold', description: 'Gold sponsorship', price: 3000 },
    ]);

    const handleDonation = async () => {
      const stripe = await stripePromise;
      if (!stripe) return;
      const response = await fetch('/create-checkout-session', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount: Number(donationAmount.value) * 100 }),
      });
      const session = await response.json();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const result = await (stripe as any).redirectToCheckout({ sessionId: session.id });
      if (result.error) {
        console.error(result.error.message);
      }
    };

    const handleSponsorship = async (levelId: number) => {
      const level = sponsorshipLevels.value.find(l => l.id === levelId);
      if (!level) return;
      const stripe = await stripePromise;
      if (!stripe) return;
      const response = await fetch('/create-checkout-session', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount: level.price, levelId }),
      });
      const session = await response.json();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const result = await (stripe as any).redirectToCheckout({ sessionId: session.id });
      if (result.error) {
        console.error(result.error.message);
      }
    };

    const uploadLogo = async () => {
      const formData = new FormData();
      if (logoFile.value) formData.append('logo', logoFile.value);
      const response = await fetch('/upload-logo', {
        method: 'POST',
        body: formData,
      });
      if (response.ok) {
        alert('Logo uploaded successfully');
      } else {
        alert('Failed to upload logo');
      }
    };

    return {
      donationAmount,
      logoFile,
      sponsorshipLevels,
      handleDonation,
      handleSponsorship,
      uploadLogo,
    };
  },
};
</script>

