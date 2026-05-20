const MOCK_PROPOSALS = [
  {
    id: 1,
    title: 'Increase AMM Fee to 0.5%',
    description: 'Proposal to increase the AMM trading fee from 0.3% to 0.5%',
    state: 1,
    votesFor: 5420,
    votesAgainst: 1230,
  },
  {
    id: 2,
    title: 'Add USDT to Lending Pool',
    description: 'Enable USDT as a borrowable asset in the lending protocol',
    state: 0,
    votesFor: 0,
    votesAgainst: 0,
  },
];

const PROPOSAL_STATES = {
  0: 'Pending',
  1: 'Active',
  2: 'Canceled',
  3: 'Defeated',
  4: 'Succeeded',
  5: 'Queued',
  6: 'Expired',
  7: 'Executed',
};

const getStateColor = (state) => {
  const colors = {
    0: 'bg-blue-600',
    1: 'bg-yellow-600',
    4: 'bg-green-600',
    3: 'bg-red-600',
  };
  return colors[state] || 'bg-gray-600';
};

export default function Governance() {
  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Governance</h1>

      <div className="space-y-4">
        {MOCK_PROPOSALS.map((proposal) => (
          <div key={proposal.id} className="bg-gray-800 p-6 rounded-lg border border-gray-700">
            <div className="flex justify-between items-start mb-4">
              <div>
                <h3 className="font-bold text-lg">#{proposal.id} - {proposal.title}</h3>
              </div>
              <span className={`${getStateColor(proposal.state)} text-white px-3 py-1 rounded text-sm font-semibold`}>
                {PROPOSAL_STATES[proposal.state]}
              </span>
            </div>

            <p className="text-sm text-gray-300 mb-4">{proposal.description}</p>

            <div className="grid grid-cols-2 gap-2 mb-4 text-sm">
              <div className="bg-gray-700 p-2 rounded">
                <p className="text-gray-400">For: {proposal.votesFor}</p>
              </div>
              <div className="bg-gray-700 p-2 rounded">
                <p className="text-gray-400">Against: {proposal.votesAgainst}</p>
              </div>
            </div>

            {proposal.state === 1 && (
              <div className="flex gap-2">
                <button className="flex-1 bg-green-600 hover:bg-green-700 px-4 py-2 rounded font-semibold">
                  👍 For
                </button>
                <button className="flex-1 bg-red-600 hover:bg-red-700 px-4 py-2 rounded font-semibold">
                  👎 Against
                </button>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
