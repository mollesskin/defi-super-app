import { useWalletContext } from '../context/WalletContext';
import SwapForm from '../components/SwapForm';
import NetworkDetector from '../components/NetworkDetector';

export default function Swap() {
  const { isConnected } = useWalletContext();

  if (!isConnected) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen gap-4">
        <h1 className="text-3xl font-bold">Swap Tokens</h1>
        <p className="text-gray-400">Please connect your wallet</p>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto">
      <NetworkDetector />
      
      <div className="bg-gray-800 p-8 rounded-lg border border-gray-700">
        <h1 className="text-3xl font-bold mb-6">Swap Tokens</h1>
        <SwapForm />
      </div>
    </div>
  );
}
