# Telecommunication Algorithm
"통신 시스템 설계" 교과목과 학부 연구생 활동을 하면서 배웠던 내용입니다.
<br><br>

## OFDM.m :

**OFDM**(Orthogonal Frequency Division Multiplexing)은 부반송파에 직교성을 부여하여 병렬 데이터열을 보내는 기법을 의미합니다. 이때 직교한다는 의미는 아래의 식을 만족하는 것을 의미합니다.

### $e^{j 2 \pi f_i t}$ 가 OFDM subcarrier일 때,

$$\
\int_{0}^{T} e^{j 2 \pi f_i t} e^{2 \pi f_k t} dt = \int_{0}^{T} e^{j 2 \pi (i - k) \Delta f t} dt = 0, \quad (i \neq j)
\$$

직교성을 가진 비트열끼리는 **서로 영향을 주지 않기 때문에** 송신단에서 보낸 여러 비트열이 합쳐지더라도 수신단에서 원 비트열을 정확히 복조해내게 됩니다. 또한 직교성을 가진 부반송파를 보내게 된다면 Guard Band를 따로 두지 않아도 ICI(Inter Carrier Interference)가 생기지 않기 때문에, **주파수 효율** 면에서 큰 이득을 얻게 됩니다.

아래는 OFDM 송/수신기 사진입니다. 왼쪽이 송신단, 오른쪽이 수신단입니다.

<img width="700" alt="image" src="https://github.com/user-attachments/assets/d3435cae-f49c-47d2-8427-35b1051f24ba">

MATLAB 코드를 활용하여 위의 OFDM 송/수신기를 구현하였습니다. 변조 방식을 QPSK, 16-QAM으로, subcarrier의 개수를 5개, 10개로 바꾸어 보면서 변조 방식이나 subcarrier의 수에 관계 없이 OFDM 송/수신이 잘 이루어지는지 확인하였습니다.

1. QPSK Input Data & 5 subcarriers
 <img width="700" alt="image" src="https://github.com/user-attachments/assets/6fe077f0-b458-4e69-bb72-aaf2acf20e4b">

2. QPSK Input Data & 10 subcarriers
 <img width="700" alt="image" src="https://github.com/user-attachments/assets/a821efa5-6e67-4d27-885b-d79997ce83ee">

3. 16-QAM Input Data & 5 subcarriers
 <img width="700" alt="image" src="https://github.com/user-attachments/assets/ee96325e-b7af-49c5-a557-b0450c9d3112">

4. 16-QAM Input Data & 10 subcarriers
 <img width="700" alt="image" src="https://github.com/user-attachments/assets/a8872f5e-7166-4749-ba22-877c1dc24d34">

시뮬레이션을 통해 subcarrier의 수나 Input Data의 변조 방식에 관계 없이 송신단에서 보낸 신호 그대로 잘 수신되는 것을 확인할 수 있었습니다.
<br><br>

## MIMO_BPSK.m, MIMO_QPSK.m :

스마트 안테나 기술에는 MIMO(Multiple-Input Multiple-Output) 기술, STC(Space Time Coding) 기술, BeamForming 기술의 세 기술의 조합으로 구성되어 있습니다.

**MIMO** 기술은 송/수신측에 다중 안테나를 사용하고 각 안테나에 **독립적인 신호**를 할당해 **간섭을 줄이고 전송 용량을 증대**하는 기술입니다. 여러 안테나를 통해 독립적인 신호들을 보내기 때문에 상대적으로 고속으로 데이터를 전송하는 효과를 보게 됩니다.

샤논의 정리에 의해 총 전송 용량은 
  
