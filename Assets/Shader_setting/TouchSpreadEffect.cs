

using System;
using UnityEngine;
using UnityEngine.UI;

[Serializable]
struct Circle_info
{
    public Circle_info(Vector2 pos, float rad, Vector4 col)
    {
        CirclePosition = pos;
        CircleRadius = rad;
        CircleColor = col;
        
    }

    public Vector2 CirclePosition;
    public float CircleRadius;
    public Vector4 CircleColor;
    

}

public class TouchSpreadEffect : MonoBehaviour
{
    public Image targetImage;                // 변경할 UI 이미지
    public Sprite test_sprite;
    public Color targetColor = Color.red;    // 타겟 색상
    public Color replaceColor = Color.green; // 대체할 색상
    [Range(0, 1)]
    public float tolerance = 0.1f;           // 허용 오차

    private Material materialInstance;       // 머티리얼 인스턴스
    private MaterialPropertyBlock mpb;
    private Vector2 touchPosition = Vector2.zero; // 터치 위치 (UV 좌표)
    private float spreadRadius = 0.0f;       // 퍼짐 반경
    private bool spreading = false;          // 퍼짐 상태


    [Header("Dynamic Shader Settings")]
    Circle_info[] Circles = new Circle_info[10];
    public Color randColor = Color.white;

    Vector4[] vec4s = {
        new Vector4(0, 1f, 0, 1),
        new Vector4(1f, 0, 0, 1),
        new Vector4(0, 0, 1f, 1),
        };

    Vector2 temp_vec2 = Vector2.zero;

    private int touchCount = 0;

    void Start()
    {
        if (targetImage != null)
        {
            materialInstance = new Material(targetImage.material);
            targetImage.material = materialInstance;
            mpb = new MaterialPropertyBlock();
            
        }

        for(int i = 0; i<Circles.Length; i++)
        {
            Circles[i].CirclePosition = new Vector2(0.5f, 0.5f);
            Circles[i].CircleColor = new Vector4(0, 0, 1f, 0);
            Circles[i].CircleRadius = 0.5f;

        }

        Debug.Log(materialInstance);
        touchCount = 0;

        // 초기 셰이더 속성 설정
        UpdateShaderProperties();
    }

    void Update()
    {
        // 터치 입력 감지
        if (Input.GetMouseButtonDown(0))
        {
            Vector2 screenPosition = Input.mousePosition;
            Debug.Log(screenPosition);
            RectTransformUtility.ScreenPointToLocalPointInRectangle(
                targetImage.rectTransform,
                screenPosition,
                null,
                out Vector2 localPoint
            );

            // 터치 위치를 UV 좌표로 변환
            Rect rect = targetImage.rectTransform.rect;
            touchPosition = new Vector2(
                (localPoint.x - rect.x) / rect.width,
                (localPoint.y - rect.y) / rect.height
            );

            Debug.Log(touchPosition);
            temp_vec2.x = touchPosition.x;
            temp_vec2.y = touchPosition.y;
            Circles[0].CirclePosition = temp_vec2;
            Circles[0].CircleRadius = 0f;
            Circles[0].CircleColor = vec4s[touchCount % 3];
            

            spreadRadius = 0.0f; // 반경 초기화
            spreading = true;    // 퍼짐 시작
        }

        // 퍼짐 효과 적용
        if (spreading)
        {
            spreadRadius += Time.deltaTime * 0.5f; // 퍼짐 속도 조절
            Circles[0].CircleRadius += Time.deltaTime * 0.5f;
            if (spreadRadius > 1.5f) // 반경이 일정 이상 커지면 멈춤
            {
                spreading = false;
            }

            UpdateShaderProperties();
        }
    }

    private void UpdateShaderProperties()
    {
        if (materialInstance != null)
        {
            //materialInstance.SetTexture("_MainTex", test_sprite.texture);
            //materialInstance.SetColor("_TargetColor", targetColor);
            //materialInstance.SetColor("_ReplaceColor", replaceColor);
            //materialInstance.SetFloat("_Tolerance", tolerance);
            //materialInstance.SetVector("_TouchPosition", touchPosition);
            //materialInstance.SetFloat("_SpreadRadius", spreadRadius);
            ComputeBuffer circlebuffer = new ComputeBuffer(Circles.Length, System.Runtime.InteropServices.Marshal.SizeOf(typeof(Circle_info)));
            circlebuffer.SetData(Circles);

            materialInstance.SetBuffer("_Circles", circlebuffer);
            Debug.Log("updating");
            Debug.Log(Circles[0].CirclePosition);

            //materialInstance.ma
        }
    }
}
