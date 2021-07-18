import chai from 'chai';
import spies from 'chai-spies';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { NFTsSwim } from '../src';

chai.use(spies);

const { assert, expect } = chai;

describe('NFTsSwim', function () {
  let contractId = '0xca791bda96927bd48d1f5afad52e1ac4996c65c2';
  let tokenId = '12';
  let order = {
    hash: 23465235634563456,
    data: {
      payouts: [],
      originFees: [],
    },
  };

  const getSellOrderURL = `https://api-staging.rarible.com/protocol/v0.1/ethereum/order/orders/sell/byItem?contract=${contractId}&tokenId=${tokenId}`;
  const prepareTXURL = `https://api-staging.rarible.com/protocol/v0.1/ethereum/order/orders/${order.hash}/prepareTx`;
  let swim = null;

  beforeEach(function () {
    swim = new NFTsSwim();
  });

  it('should construct without errors', function () {
    assert(swim, true);
  });

  it('should call getSellOrdersByItem method and return response data', async function () {
    const spy = chai.spy(swim.getSellOrdersByItem);
    spy({ contractId, tokenId });
    expect(spy).to.have.been.called.with({ contractId, tokenId });

    let mock = new MockAdapter(axios);
    mock.onGet(getSellOrderURL).reply(function () {
      return [200, 'success'];
    });

    try {
      const response = await swim.getSellOrdersByItem({
        contractId,
        tokenId,
      });

      expect(response.data).to.equal('success');
    } catch (error) {
      console.error(error.message);
    }
  });

  it('should call createPool', function () {
    const createPoolSpy = chai.spy(swim.createPool);
    // const getSellOrdersByItemSpy = chai.spy(swim.getSellOrdersByItem);
    // const getPreparedOrdersFromSpy = chai.spy(swim.getPreparedOrdersFrom);
    // const prepareTXSpy = chai.spy(swim.prepareTX);

    createPoolSpy({ contractId, tokenId });
    expect(createPoolSpy).to.have.been.called();
  });

  it('should call getPreparedOrdersFrom and return prepared ordered', async function () {
    const spy = chai.spy(swim.getPreparedOrderFrom);
    await spy(order);
    expect(spy).to.have.been.called.with(order);
  });

  it('should call prepareTX and return response', async function () {
    const spy = chai.spy(swim.prepareTX);
    console.log('DATA: ', order);
    await spy(order);
    expect(spy).to.have.been.called.with(order);

    let mock = new MockAdapter(axios);
    mock.onGet(prepareTXURL).reply(function () {
      return [200, 'success'];
    });

    try {
      const response = await swim.prepareTX({
        order,
      });

      expect(response.data).to.equal('success');
    } catch (error) {
      console.error(error.message);
    }
  });
});
